#lang racket

(require advent-of-code
         threading)

(define (parse-input input [state 'block] [index 0] [acc '()])
  (match* (state input)
    [(_ '()) (reverse acc)]
    [('block (list* h t))
     (~> h
         string
         string->number
         (make-list index)
         (append acc)
         (parse-input t 'empty (add1 index) _))]
    [('empty (list* h t))
     (~> h string string->number (make-list 'empty) (append acc) (parse-input t 'block index _))]))

(define disk
  (~> (fetch-aoc-input (find-session) 2024 9 #:cache #t) string-trim string->list parse-input))

;; part 1
(define free-spaces (count (curry equal? 'empty) disk))
(define filled-spaces (- (length disk) free-spaces))

(define move-steps (~> disk (take filled-spaces) (count (curry equal? 'empty) _)))

(define fixed-blocks (take disk filled-spaces))
(define moving-blocks (~> disk reverse (filter number? _) (take move-steps)))

(define (replace fixed moving [index 0] [acc 0])
  (match* (fixed moving)
    [('() '()) acc]
    [((list* b rest-fixed) '()) (replace rest-fixed '() (add1 index) (+ acc (* b index)))]
    [((list* 'empty rest-fixed) (list* b rest-moving))
     (replace rest-fixed rest-moving (add1 index) (+ acc (* b index)))]
    [((list* b rest-fixed) _) (replace rest-fixed moving (add1 index) (+ acc (* b index)))]))

(replace fixed-blocks moving-blocks)

;; part 2
(struct file (size id) #:transparent)
(struct free (size) #:transparent)

(define (find-free-space drive files)
  (cond
    [(empty? files) drive]
    [else
     (match-define (list* (and next (file next-size next-id)) remaining) files)
     (match/values
      (splitf-at drive
                 (match-λ [(file _size id) (not (= next-id id))] [(free size) (< size next-size)]))
      [(_ (or '() (list* (file _ _) _))) (find-free-space drive remaining)]
      [(left (list* (free (== next-size)) fs))
       (define after-move (collapse-free-space fs next))
       (find-free-space (append left (cons next after-move)) remaining)]
      [(left (list* (free size) fs))
       (define after-move (collapse-free-space fs next))
       (find-free-space (append left (cons next (cons (free (- size next-size)) after-move)))
                        remaining)])]))

(define (collapse-free-space drive moved [acc '()])
  (define moved-size (file-size moved))
  (match drive
    [(list* (free a) (== moved) (free b) remaining)
     (append (reverse acc) (cons (free (+ a b moved-size)) remaining))]
    [(list* (free a) (== moved) remaining)
     (append (reverse acc) (cons (free (+ a moved-size)) remaining))]
    [(list* (== moved) (free b) remaining)
     (append (reverse acc) (cons (free (+ b moved-size)) remaining))]
    [(list* (== moved) remaining) (append (reverse acc) (cons (free moved-size) remaining))]
    [(list* other remaining) (collapse-free-space remaining moved (cons other acc))]
    ['() (reverse acc)]))

(define (parse-drive-files input [state 'file] [index 0] [acc '()])
  (match* (state input)
    [(_ '()) (reverse acc)]
    [('file (list* h t))
     (parse-drive-files t 'empty (add1 index) (cons (file (~> h string string->number) index) acc))]
    [('empty (list* h t))
     (parse-drive-files t 'file index (cons (free (~> h string string->number)) acc))]))

(define drive-files
  (~> (fetch-aoc-input (find-session) 2024 9 #:cache #t) string-trim string->list parse-drive-files))

(define files (~>> drive-files (filter file?) reverse))
(define sorted-drive (find-free-space drive-files files))
(define blocks
  (for/list ([f (in-list sorted-drive)])
    (match f
      [(file size id) (make-list size id)]
      [(free size) (make-list size 0)])))

(for/sum ([(b i) (in-indexed (flatten blocks))]) (* b i))

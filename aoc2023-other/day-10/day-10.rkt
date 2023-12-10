#lang racket

(require advent-of-code
         threading)

(struct posn (r c) #:transparent)

(define/match (add-posns _p1 _p2)
  [((posn x1 y1) (posn x2 y2)) (posn (+ x1 x2) (+ y1 y2))])

(define go-north (posn -1 0))
(define go-south (posn 1 0))
(define go-east (posn 0 1))
(define go-west (posn 0 -1))

(define initial-directions
  (list (cons go-north '(#\| #\7 #\F))
        (cons go-south '(#\| #\J #\L))
        (cons go-east '(#\- #\J #\7))
        (cons go-west '(#\- #\F #\L))))

(define/match (pipe-neighbors _pipe)
  [(#\|) (list go-north go-south)]
  [(#\-) (list go-east go-west)]
  [(#\L) (list go-north go-east)]
  [(#\F) (list go-south go-east)]
  [(#\7) (list go-south go-west)]
  [(#\J) (list go-north go-west)])

(define (make-pipe-grid in)
  (for*/hash ([(row r) (in-indexed (string-split in "\n"))] [(ch c) (in-indexed (string->list row))])
    (values (posn (add1 r) (add1 c)) ch)))

(define (get-valid-S-neighbors S grid)
  (for/list ([dir (in-list initial-directions)]
             #:do [(match-define (cons d valid) dir)]
             #:do [(define neighbor (add-posns d S))]
             #:when (member (hash-ref grid neighbor 'none) valid))
    neighbor))

(define (to-next-pipe current previous grid [acc '()])
  (cond
    [(equal? (hash-ref grid current #f) #\S) acc]
    [else
     (define next
       (for/first ([d (in-list (pipe-neighbors (hash-ref grid current)))]
                   #:do [(define neighbor (add-posns d current))]
                   #:unless (equal? neighbor previous))
         neighbor))
     (~> next (to-next-pipe _ current grid (cons current acc)))]))

;; part 1
(define input (fetch-aoc-input (find-session) 2023 10 #:cache #true))

(define pipe-grid (make-pipe-grid input))

(define S-posn
  (for/first ([(k v) (in-hash pipe-grid)] #:when (equal? v #\S))
    k))

(define S-neighbors (get-valid-S-neighbors S-posn pipe-grid))

(define pipe-loop (to-next-pipe (first S-neighbors) S-posn pipe-grid '()))

(/ (add1 (length pipe-loop)) 2)

;; part 2
(define pipe-loop-set (~> (list->set pipe-loop) (set-add S-posn)))

(define (trace-rays pt pipes grid)
  (cond
    [(set-member? pipes pt) #f]
    [else (odd? (trace-ray pt pipes grid))]))

(define (trace-ray pt pipes grid)
  (define row (posn-r pt))
  (for/fold ([acc 0] [corner #f] #:result acc)
            ([col (in-naturals (posn-c pt))]
             #:do [(define test-pt (posn row col))]
             #:break (not (hash-has-key? grid test-pt))
             #:when (set-member? pipes test-pt))
    (define pipe (hash-ref grid test-pt))
    (match* (pipe corner)
      [(#\| #f) (values (add1 acc) #f)] ; vertical crossing
      [((or #\F #\L) #f) (values acc pipe)]
      [(#\J #\F) (values (add1 acc) #f)] ; a  ┏━┛ shape counts as a vertical crossing
      [(#\7 #\L) (values (add1 acc) #f)]
      [(#\7 #\F) (values acc #f)] ; a  ┏━┓ shape doesn't count
      [(#\J #\L) (values acc #f)]
      [(_ _) (values acc corner)])))

(~> pipe-grid hash-keys (count (λ~> (trace-rays pipe-loop-set pipe-grid)) _))

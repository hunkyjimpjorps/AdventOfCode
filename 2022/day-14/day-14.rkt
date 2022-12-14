#lang racket

(require advent-of-code
         threading
         algorithms)

(define data (fetch-aoc-input (find-session) 2022 14 #:cache #true))

(define (trace-line-between-points p1 p2)
  (match* (p1 p2)
    [((list x y1) (list x y2))
     (for/list ([y [in-inclusive-range (min y1 y2) (max y1 y2)]])
       (cons x y))]
    [((list x1 y) (list x2 y))
     (for/list ([x [in-inclusive-range (min x1 x2) (max x1 x2)]])
       (cons x y))]))

(define all-coordinates
  (apply append
         (for/list ([formation (in-list (string-split data "\n"))])
           (define coord-list
             (for/list ([coord-pair (in-list (string-split formation " -> "))])
               (for/list ([coord (in-list (string-split coord-pair ","))])
                 (string->number coord))))
           (apply append (adjacent-map trace-line-between-points coord-list)))))

(define rock-structures-hash
  (for/hash ([p (in-list all-coordinates)])
    (values p 'rock)))

(define max-vertical-distance (~>> all-coordinates (argmax cdr) cdr add1))

(define (open? h x y)
  (not (hash-has-key? h (cons x y))))

;; part 1
(define (trace-grain h [pos (cons 500 0)])
  (match-define (cons x y) pos)
  (cond
    [(> y max-vertical-distance) 'break]
    [(open? h x (add1 y)) (trace-grain h (cons x (add1 y)))]
    [(open? h (sub1 x) (add1 y)) (trace-grain h (cons (sub1 x) (add1 y)))]
    [(open? h (add1 x) (add1 y)) (trace-grain h (cons (add1 x) (add1 y)))]
    [else (hash-set h (cons x y) 'sand)]))

(for/fold ([h rock-structures-hash] [grains 0] #:result grains) ([_ (in-naturals 1)])
  (define h* (trace-grain h))
  #:break (eq? h* 'break)
  (values h* (add1 grains)))

;; part 2
(define (trace-grain* h [pos (cons 500 0)])
  (match-define (cons x y) pos)
  (cond
    [(= y max-vertical-distance) (hash-set h (cons x y) 'sand)]
    [(open? h x (add1 y)) (trace-grain* h (cons x (add1 y)))]
    [(open? h (sub1 x) (add1 y)) (trace-grain* h (cons (sub1 x) (add1 y)))]
    [(open? h (add1 x) (add1 y)) (trace-grain* h (cons (add1 x) (add1 y)))]
    [else (hash-set h (cons x y) 'sand)]))

(for/fold ([h rock-structures-hash] [grains 0] #:result grains) ([_ (in-naturals 1)])
  #:break (not (open? h 500 0))
  (define h* (trace-grain* h))
  (values h* (add1 grains)))

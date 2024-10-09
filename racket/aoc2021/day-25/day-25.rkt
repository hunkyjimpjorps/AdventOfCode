#lang racket
(require "../../jj-aoc.rkt"
         threading)

(define sea-floor
  (for*/hash ([(row i) (in-indexed (in-lines (open-day 25 2021)))] [(c j) (in-indexed row)])
    (values (list i j) c)))

(define-values (max-i max-j)
  (~> sea-floor hash-keys (argmax (λ (coord) (apply + coord)) _) (apply values _)))

(define (cucumber-movement h c delta-i delta-j)
  (define new-hash (hash-copy h))
  (for* ([(coord x) (in-hash h)] #:when (eq? x c))
    (match-define (list i j) coord)
    (define neighbor (list (+ delta-i i) (+ delta-j j)))
    (define neighbor-or-wrap
      (if (hash-has-key? h neighbor) neighbor (list (if (= delta-i 0) i 0) (if (= delta-j 0) j 0))))
    (when (eq? #\. (hash-ref h neighbor-or-wrap))
      (hash-set*! new-hash coord #\. neighbor-or-wrap c)))
  new-hash)

(define (eastwards-movement h)
  (cucumber-movement h #\> 0 1))

(define (southwards-movement h)
  (cucumber-movement h #\v 1 0))

;; part 1
(for/fold ([f sea-floor] [step 0] #:result (add1 step)) ([i (in-naturals 1)])
  (define f* (~> f eastwards-movement southwards-movement))
  #:break (equal? f* f)
  (values f* i))

;; no part 2 -- merry Christmas

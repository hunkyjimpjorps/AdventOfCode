#lang racket
(require "../../jj-aoc.rkt"
         threading)

(define entries
  (~>> (open-day 01 2020)
       (port->list read)
       list->set))

;; part 1
(define (look-for-complement xs)
  (define x (set-first xs))
  (cond
    [(set-member? xs (- 2020 x)) (* x (- 2020 x))]
    [else (look-for-complement (set-rest xs))]))

(time (look-for-complement entries))

;; part 2
(time (for*/first ([x (in-set entries)]
                   [y (in-set (set-subtract entries (set x)))]
                   #:when (set-member? (set-subtract entries (set x y)) (- 2020 x y)))
        (* x y (- 2020 x y))))
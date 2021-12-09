#lang racket
(require "../../jj-aoc.rkt"
         threading)

(define (check-for-trees run rise)
  (for*/sum ([(row i) (in-indexed (port->lines (open-day 3 2020)))]
             #:when (= 0 (modulo i rise))
             [possible-tree (in-value (sequence-ref (in-cycle row) (* (/ run rise) i)))]
             #:when (and (char=? possible-tree #\#)))
    1))

;; part 1
(check-for-trees 3 1)

;; part 2
(~>> '((1 1)
       (3 1)
       (5 1)
       (7 1)
       (1 2))
     (map (curry apply check-for-trees))
     (apply *))
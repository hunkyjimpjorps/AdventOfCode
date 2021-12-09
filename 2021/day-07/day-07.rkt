#lang racket
(require advent-of-code
         threading
         math/statistics)

(define crab-data
  (~> (open-aoc-input (find-session) 2021 7 #:cache #t)
      port->string
      string-trim
      (string-split ",")
      (map string->number _)))

(define (gauss-sum n) (/ (* n (+ n 1)) 2))
(define (compute-fuel-use f crabs align-to)
  (for/sum ([crab (in-list crabs)])
    (f (abs (- crab align-to)))))

;; using the fact that the optimum location is at the median
;; of the crabs' starting location for the linear relationship
;; and at a coordinate within 1 unit of the mean for the quadratic one

(~>> crab-data
     (median <)
     (compute-fuel-use identity crab-data))

(~>> crab-data
     mean
     ((λ (m) (list (floor m) (ceiling m))))
     (map (curry compute-fuel-use gauss-sum crab-data))
     (apply min))
#lang racket
(define/contract (sum-zero n)
  (-> exact-integer? (listof exact-integer?))
  (cond [(even? n) (remove 0 (range (/ n -2) (add1 (/ n 2))))]
        [(odd? n)  (range (/ (- n 1) -2) (add1 (/ (- n 1) 2)))]))
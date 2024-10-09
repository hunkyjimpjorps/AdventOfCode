#lang racket

(define/contract (is-one-bit-character bits)
  (-> (listof exact-integer?) boolean?)
  (define/match (check-next-character x . xs)
    [(0 '())          #true]
    [(1 (list _ ..2)) (apply check-next-character (cdr xs))]
    [(0 (list _ ..1)) (apply check-next-character xs)]
    [(_ _)            #false])
  (apply check-next-character bits))

(is-one-bit-character (list 1 1 0 1 0))
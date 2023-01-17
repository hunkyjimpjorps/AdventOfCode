#lang racket

(define (flip-bit bit)
  (cond [(char=? bit #\1) #\0]
        [(char=? bit #\0) #\1]))

(define/contract (find-complement num)
  (-> exact-integer? exact-integer?)
  (define num-binary-list
    (string->list (number->string num 2)))
  (string->number (apply ~a (map flip-bit num-binary-list)) 2))
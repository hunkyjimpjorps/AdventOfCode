#lang racket

(define max-r 2978)
(define max-c 3083)

(for/fold ([code 20151125] [r 1] [c 1]) ([i (in-naturals)] #:break (and (= max-r r) (= max-c c)))
  (define new-code (modulo (* code 252533) 33554393))
  (if (= r 1) (values new-code (add1 c) 1) (values new-code (sub1 r) (add1 c))))

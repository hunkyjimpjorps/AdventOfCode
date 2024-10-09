#lang racket
(define/contract (prefixes-div-by5 A)
  (-> (listof exact-integer?) (listof boolean?))
  (define ns (make-vector (length A) #false))
  (for/fold ([acc 0])
            ([b (in-list A)]
             [i (in-naturals)])
    (let ([test-val (remainder (+ (* 2. acc) b) 5)])
      (when (= 0 test-val) (vector-set! ns i #true))
      test-val))
  (vector->list ns))
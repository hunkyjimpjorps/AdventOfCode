#lang racket
(define/contract (busy-student start-time end-time query-time)
  (-> (listof exact-integer?) (listof exact-integer?) exact-integer? exact-integer?)
  (count (λ (start end)
           (and (start . <= . query-time)
                (query-time . <= . end))) start-time end-time))

(busy-student '(1 2 3) '(3 2 7) 4)
(busy-student '(4) '(4) 4)
(busy-student '(9  8  7  6  5  4  3  2  1)
              '(10 10 10 10 10 10 10 10 10)
              5)
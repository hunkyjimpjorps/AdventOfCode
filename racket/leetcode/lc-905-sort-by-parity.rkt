#lang racket
(define/contract (sort-array-by-parity A)
  (-> (listof exact-integer?) (listof exact-integer?))
  ((compose flatten (if (odd? (car A)) reverse identity))
   (group-by (λ (n) (modulo n 2)) A)))

(sort-array-by-parity '(1 1 3 4))
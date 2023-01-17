#lang racket
(define/contract (find-numbers nums)
  (-> (listof exact-integer?) exact-integer?)
  (count (λ (n) (odd? (order-of-magnitude n))) nums))
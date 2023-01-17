#lang racket
(define/contract (can-be-equal target arr)
  (-> (listof exact-integer?) (listof exact-integer?) boolean?)
  (equal? (sort target <) (sort arr <)))
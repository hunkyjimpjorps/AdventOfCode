#lang racket/base
(define/contract (rotate-string A B)
  (-> string? string? boolean?)
  (define doubled-A (string-append A A))
  (and (= (string-length A) (string-length B))
       (string-contains? doubled-A B)))
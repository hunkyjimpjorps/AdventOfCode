#lang racket
(define/contract (min-deletion-size strs)
  (-> (listof string?) exact-integer?)
  (define transposed-strs (apply map list (map string->list strs)))
  (count (λ (s) (not (equal? s (sort s char<?)))) transposed-strs))

(min-deletion-size '["cba" "daf" "ghi"])

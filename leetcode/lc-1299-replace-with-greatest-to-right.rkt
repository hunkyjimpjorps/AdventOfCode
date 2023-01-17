#lang racket
(define/contract (replace-elements arr)
  (-> (listof exact-integer?) (listof exact-integer?))
  (cond [(= 1 (length arr)) '(-1)]
        [else (cons (apply max (cdr arr))
                    (replace-elements (cdr arr)))]))

(replace-elements '(17 18 5 4 6 1))
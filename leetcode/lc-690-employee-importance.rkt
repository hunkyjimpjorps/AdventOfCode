#lang racket

(define/contract (sum-even-after-queries A queries)
  (-> (listof exact-integer?)
      (listof (listof exact-integer?))
      (listof exact-integer?))
  (define array (list->vector A))
  (for/list ([query (in-list queries)])
    (vector-set! array
                 (second query)
                 (+ (first query) (vector-ref array (second query))))
    (for/sum ([element (vector-filter even? array)]) element)))

(sum-even-after-queries '[1 2 3 4] '[[1 0] [-3 1] [-4 0] [2 3]])
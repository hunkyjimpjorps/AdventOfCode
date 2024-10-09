#lang racket
(require rackunit)

(define/contract (balanced-string-split s)
  (-> string? exact-integer?)
  (for/fold ([acc 0]
             [count 0]
             #:result count)
            ([c (string->list s)])
    (let* ([increment (case c
                        [(#\R) 1]
                        [(#\L) -1])]
           [new-acc (+ increment acc)]
           [new-count (case new-acc
                        [(0) (add1 count)]
                        [else count])])
      (values new-acc new-count))))

(check-eq? (balanced-string-split "RLRRLLRLRL") 4) 
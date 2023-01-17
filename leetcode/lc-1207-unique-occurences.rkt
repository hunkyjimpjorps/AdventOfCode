#lang racket
(define/contract (unique-occurrences arr)
  (-> (listof exact-integer?) boolean?)
  (define occurrences (make-hash))
  (for ([n (in-list arr)])
    (hash-update! occurrences n add1 1))
  (equal? (hash-values occurrences)
          (remove-duplicates (hash-values occurrences))))

(unique-occurrences '(1 2 2 1 1 3))
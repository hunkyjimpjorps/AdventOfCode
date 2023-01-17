#lang racket
(define/contract (dominant-index nums)
  (-> (listof exact-integer?) exact-integer?)
  (if (empty? (cdr nums))
      0
      (let* ([indexed-list
              (map cons nums (range (length nums)))]
             [sorted-indexed-list
              (sort indexed-list > #:key car)])
        (if ((car (first sorted-indexed-list)) . >= . (* 2 (car (second sorted-indexed-list))))
            (cdr (first sorted-indexed-list))
            -1))))

(dominant-index '(3 6 1 0))
(dominant-index '(0))
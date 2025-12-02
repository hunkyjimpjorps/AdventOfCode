#lang racket

(require advent-of-code
         threading
         rebellion/base/comparator
         rebellion/base/range
         rebellion/collection/range-set)

(define id-ranges
  (for/range-set
   #:comparator real<=>
   ([rng (~> (fetch-aoc-input (find-session) 2025 2 #:cache #true) (string-trim) (string-split ","))])
   (~> rng (string-split "-") (map string->number _) (apply closed-range _))))

;; part 1
(for/sum ([n (in-inclusive-range 1 99999)] ;
          #:do [(define len (inexact->exact (ceiling (log n 10))))]
          #:do [(define nn (+ n (* n (expt 10 len))))]
          #:when (range-set-contains? id-ranges nn))
         nn)

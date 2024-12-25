#lang racket

(require advent-of-code
         threading
         "utils/list.rkt")

(define-values (locks keys)
  (~> (fetch-aoc-input (find-session) 2024 25 #:cache #true)
      (string-split "\n\n")
      (partition (λ~> (string-prefix? "#")) _)))

(define (to-heights str)
  (~> str
      (string-split "\n")
      (map string->list _)
      transpose
      (map (λ~> (count (curry equal? #\#) _) sub1) _)))

(define (fits? lock key)
  (for/and ([lock-tumbler (in-list (to-heights lock))]
            [key-ridge (in-list (to-heights key))])
    ((+ lock-tumbler key-ridge) . <= . 5)))

;; part 1
(for*/sum ([lock (in-list locks)] [key (in-list keys)] #:when (fits? lock key)) 1)

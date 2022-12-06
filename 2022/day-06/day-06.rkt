#lang racket

(require advent-of-code
         threading
         (only-in relation ->list ->set)
         (only-in algorithms sliding))

(define buffer (~> (fetch-aoc-input (find-session) 2022 6)))

(define (find-marker data type)
  (define n
    (match type
      ['start-of-packet 4]
      ['start-of-message 14]))
  (for/first ([chunk (in-list (sliding (->list data) n))]
              [i (in-naturals n)]
              #:when (= n (~> chunk remove-duplicates length)))
    i))

;; part 1
(find-marker buffer 'start-of-packet)

;; part 2
(find-marker buffer 'start-of-message)

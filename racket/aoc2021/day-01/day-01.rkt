#lang racket
(require advent-of-code
         threading)

;; part 1
(define sensor-data
  (~> (open-aoc-input (find-session) 2021 1 #:cache (string->path "./cache"))
      (port->list read _)))

(define (count-increases data offset)
  (for/sum ([x (in-list data)]
            [y (in-list (drop data offset))]
            #:when (< x y))
    1))

(~a "Part 1: " (count-increases sensor-data 1))

;; part 2

(~a "Part 2: " (count-increases sensor-data 3))
#lang racket
(require advent-of-code)
(provide open-day)

(define (open-day n [year 2021])
  (open-aoc-input (find-session) year n #:cache (string->path "../../cache")))
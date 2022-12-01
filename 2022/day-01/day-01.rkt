#lang racket

(require advent-of-code
         threading)

(define calorie-data (fetch-aoc-input (find-session) 2022 1))

;; part 1
(~> calorie-data
    (string-split "\n\n")
    (map (λ~> string-split (map string->number _) (apply + _)) _)
    (apply max _))

;; part 2
(~> calorie-data
    (string-split "\n\n")
    (map (λ~> string-split (map string->number _) (apply + _)) _)
    (sort _ >)
    (take 3)
    (apply + _))

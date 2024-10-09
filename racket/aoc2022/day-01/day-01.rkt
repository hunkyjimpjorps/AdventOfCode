#lang racket

(require advent-of-code
         threading)

(define calorie-data (fetch-aoc-input (find-session) 2022 1))

;; part 1
(~>> calorie-data
     (string-split _ "\n\n")
     (map (λ~>> string-split (map string->number) (apply +)))
     (apply max))

;; part 2
(~>> calorie-data
     (string-split _ "\n\n")
     (map (λ~>> string-split (map string->number) (apply +)))
     (sort _ >)
     (take _ 3)
     (apply +))

#lang racket

(require advent-of-code
         threading)

(define input (fetch-aoc-input (find-session) 2024 03 #:cache #true))

(define (find-with pattern)
  (~> input (regexp-match* pattern _ #:match-select values) (do-next)))

(define (do-next instructions [acc 0] [doing 'do])
  (match* (instructions doing)
    [('() _) acc]
    [((list* (list "do()" _ _) rest) _) (do-next rest acc 'do)]
    [((list* (list "don't()" _ _) rest) _) (do-next rest acc 'dont)]
    [((list* _ rest) 'dont) (do-next rest acc 'dont)]
    [((list* (list _ (app string->number a) (app string->number b)) rest) 'do)
     (do-next rest (+ acc (* a b)) 'do)]))

;; part 1
(find-with #px"mul\\((\\d+),(\\d+)\\)")

;; part 2
(find-with #px"mul\\((\\d+),(\\d+)\\)|don't\\(\\)|do\\(\\)")

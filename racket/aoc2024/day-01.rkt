#lang racket

(require advent-of-code
         threading
         list-utils)

;; part 1
(match-define (list as bs)
  (~> (fetch-aoc-input (find-session) 2024 1 #:cache #true)
      (string-split "\n")
      (map (λ~> (string-split "   ") (map string->number _)) _)
      (apply map list _)
      (map (curryr sort <) _)))
(for/sum ([a (in-list as)] [b (in-list bs)]) (abs (- a b)))

;; part 2
(define copies (frequencies bs))
(for/sum ([a (in-list as)]) (* a (hash-ref copies a 0)))

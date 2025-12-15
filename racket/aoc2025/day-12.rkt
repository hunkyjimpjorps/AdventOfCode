#lang racket

(require advent-of-code
         threading)

(define input (fetch-aoc-input (find-session) 2025 12 #:cache #true))
;; the shapes don't matter, so we can toss them
(match-define (list _raw-shapes __5 raw-regions) (string-split input "\n\n"))

(struct Region (width height presents))
(define regions
  (for/list ([line (in-list (string-split raw-regions "\n"))])
    (match-define (list shape raw-presents) (string-split line ": "))
    (match-define (list width height) (~> shape (string-split "x") (map string->number _)))
    (define presents (~> raw-presents (string-split " ") (map string->number _)))
    (Region width height presents)))

;; part 1
(for/sum ([region (in-list regions)] ;
          #:do [(match-define (Region w h ps) region)]
          #:when ((* w h) . >= . (* 9 (apply + ps))))
         1)

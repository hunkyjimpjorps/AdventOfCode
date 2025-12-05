#lang racket

(require advent-of-code
         threading
         (prefix-in iset: data/integer-set))

(match-define (list raw-ranges raw-ingredients)
  (string-split (fetch-aoc-input (find-session) 2025 5 #:cache #true) "\n\n"))

(define ranges
  (for/fold ([acc (iset:make-range)]) ([line (in-list (string-split raw-ranges))])
    (~>> line (string-split _ "-") (map string->number) (apply iset:make-range) (iset:union acc))))

(define ingredients (~> raw-ingredients string-split (map string->number _)))

;; part 1
(count (λ~> (iset:member? ranges)) ingredients)

;; part 2
(iset:count ranges)

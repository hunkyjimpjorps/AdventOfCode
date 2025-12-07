#lang racket

(require advent-of-code
         threading
         "../jj-aoc.rkt")

(define input (fetch-aoc-input (find-session) 2025 6 #:cache #true))

;; part 1
(define/match (f _str)
  [("+") +]
  [("*") *])

(define (math1 cols [acc 0])
  (match cols
    [(list) acc]
    [(list* (list* op xs) rest) (math1 rest (+ acc (apply (f op) (map string->number xs))))]))

(~> input (string-split "\n") reverse (map (λ~> (string-split " " #:repeat? #t)) _) transpose math1)

;;part 2
(define (undigits strs)
  (~> strs (apply string _) (string-trim " " #:repeat? #t) string->number))

(define (math2 cols [acc 0] [register '()] [op #f])
  (match cols
    [(list) (+ acc (apply (f op) register))]
    [(list* (list #\space ...) rest) (math2 rest (+ acc (apply (f op) register)) '() #f)]
    [(list* (list ch ... #\space) rest) (math2 rest acc (cons (undigits ch) register) op)]
    [(list* (list ch ... new-op) rest)
     (math2 rest acc (cons (undigits ch) register) (string new-op))]))

(~> input (string-split "\n") (map string->list _) transpose math2)

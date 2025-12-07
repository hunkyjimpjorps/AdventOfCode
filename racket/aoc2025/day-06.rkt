#lang racket

(require advent-of-code
         threading
         "../jj-aoc.rkt")

(define input (fetch-aoc-input (find-session) 2025 6 #:cache #true))

;; part 1
(define/match (f _str)
  [("+") +]
  [("*") *])

(for/sum
 ([col
   (in-list
    (~> input (string-split "\n") reverse (map (λ~> (string-split " " #:repeat? #t)) _) transpose))])
 (apply (f (first col)) (~> col rest (map string->number _))))

;;part 2
(define (undigits strs)
  (~> strs (apply string _) (string-trim " " #:repeat? #t) string->number))

(for/fold ([acc 0]
           [register '()]
           [op #f]
           #:result (+ acc (apply (f op) register)))
          ([col (~> input (string-split "\n") (map string->list _) transpose)])
  (match col
    [(list #\space ...) (values (+ acc (apply (f op) register)) '() #f)]
    [(list ch ... #\space) (values acc (cons (undigits ch) register) op)]
    [(list ch ... new-op) (values acc (cons (undigits ch) register) (string new-op))]))

#lang racket
(require advent-of-code)
(provide open-day
         transpose
         chunks-by)

(define (open-day n [year 2021])
  (open-aoc-input (find-session) year n #:cache (string->path "./cache")))

(define (transpose xss)
  (apply map list xss))

(define (chunks-by xs [by identity])
  (define (do-chunks-by xs by group result)
    (match* (xs group)
      [('() _) (reverse (cons group result))]
      [((list* h t) '()) (do-chunks-by t by (cons h group) result)]
      [((list* h t) (list* g _))
       #:when (equal? (by h) (by g))
       (do-chunks-by t by (cons h group) result)]
      [((list* h t) _) (do-chunks-by t by (list h) (cons group result))]))
  (do-chunks-by xs by '() '()))

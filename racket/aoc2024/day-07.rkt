#lang racket

(require advent-of-code
         data/applicative
         data/either
         data/monad
         megaparsack
         megaparsack/text
         threading)

(struct Problem (answer terms) #:transparent)
(define problem/p
  (do [answer <- integer/p]
      (string/p ": ")
      [terms <- (many+/p integer/p #:sep space/p)]
      (pure (Problem answer terms))))

(define PROBLEMS
  (for/list ([problem (in-lines (open-aoc-input (find-session) 2024 7 #:cache #true))])
    (~>> problem (parse-string problem/p) from-either)))

(define (do-op op a b)
  (match op
    ['add (+ a b)]
    ['mul (* a b)]
    ['con (concat a b)]))

(define (concat a b)
  (define power (floor (add1 (log b 10))))
  (inexact->exact (+ (* a (expt 10 power)) b)))

(define (check-problem problem ops)
  (match problem
    [(Problem answer (list* a _))
     #:when (< answer a)
     #f]
    [(Problem answer (list a))
     #:when (= answer a)
     a]
    [(Problem answer (list* a b rest))
     (for/or ([op (in-list ops)])
       (check-problem (Problem answer (cons (do-op op a b) rest)) ops))]
    [_ #f]))

(define (find-checksum ops)
  (for/sum ([problem (in-list PROBLEMS)] ;
            #:do [(define checksum (check-problem problem ops))]
            #:when checksum)
           checksum))

;; part 1
(find-checksum '(add mul))

;; part 2
(find-checksum '(add mul con))

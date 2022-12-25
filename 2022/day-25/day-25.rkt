#lang racket
(require advent-of-code
         threading)

(define fuel-requirements (port->lines (open-aoc-input (find-session) 2022 25 #:cache #true)))

(define (snafu->decimal snafu)
  (for/sum ([digit (in-list (~> snafu string->list reverse))] [place (in-naturals)])
           (define value
             (match digit
               [#\= -2]
               [#\- -1]
               [c (~> c string string->number)]))
           (* value (expt 5 place))))

(define (decimal->snafu n [acc '()])
  (match n
    [0 (list->string acc)]
    [n (decimal->snafu (quotient (+ n 2) 5) (cons (string-ref "012=-" (modulo n 5)) acc))]))

;; part 1
(~> (for/sum ([fuel (in-list fuel-requirements)]) (snafu->decimal fuel)) decimal->snafu)

;; no part 2 メリークリスマス
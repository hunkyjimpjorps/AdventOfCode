#lang racket

(require advent-of-code
         memo
         threading)

(define STONES
  (for/list ([n (string-split (fetch-aoc-input (find-session) 2024 11 #:cache #true))])
    (string->number n)))

(define (digits n)
  (~> n (log 10) add1 floor inexact->exact))

(define (split n)
  (call-with-values (λ () (quotient/remainder n (expt 10 (quotient (digits n) 2)))) list))

(define/memoize
 (transform-stone stone blinks)
 (cond
   [(= blinks 0) 1]
   [(= stone 0) (transform-stone 1 (sub1 blinks))]
   [(even? (digits stone)) (~>> stone split (map (λ~> (transform-stone (sub1 blinks)))) (apply +))]
   [else (transform-stone (* stone 2024) (sub1 blinks))]))

(define (blink n)
  (for/sum ([stone (in-list STONES)]) (transform-stone stone n)))

;; part 1
(blink 25)

;; part 2
(blink 75)

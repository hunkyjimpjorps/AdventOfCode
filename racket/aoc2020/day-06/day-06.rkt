#lang racket
(require "../../jj-aoc.rkt"
         threading)

(define responses (~> (open-day 6 2020) (port->string) (string-split "\n\n")))

;; part 1
(define (response-count-total rs)
  (for/sum ([r (in-list rs)]) (~> r (string-replace _ "\n" "") string->list list->set set-count)))

(response-count-total responses)

;; part 2
(define (response-consensus-total rs)
  (for/sum ([r (in-list rs)])
           (~> r
               (string-split _ "\n")
               (map (λ~> string->list list->set) _)
               (apply set-intersect _)
               set-count)))

(response-consensus-total responses)
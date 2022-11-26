#lang racket
(require "../../jj-aoc.rkt")

;; part 1
(for/fold ([current-floor 0]) ([l (in-input-port-chars (open-day 1 2015))] [i (in-naturals)])
  (match l
    [#\( (add1 current-floor)]
    [#\) (sub1 current-floor)]))

;; part 2
(for/fold ([current-floor 0] [last-index 0] #:result (add1 last-index))
          ([l (in-input-port-chars (open-day 1 2015))] [i (in-naturals)])
  #:break (= current-floor -1)
  (match l
    [#\( (values (add1 current-floor) i)]
    [#\) (values (sub1 current-floor) i)]))

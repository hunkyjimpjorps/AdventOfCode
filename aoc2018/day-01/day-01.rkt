#lang racket

(require advent-of-code
         threading)

(define deltas
  (~>> (open-aoc-input (find-session) 2018 1 #:cache #true) port->lines (map string->number)))

;; part 1
(for/sum ([delta deltas]) delta)

;; part 2
(for/fold ([seen (set)] [current-frequency 0] #:result current-frequency) ([delta (in-cycle deltas)])
  (define new-frequency (+ current-frequency delta))
  #:final (set-member? seen new-frequency)
  (values (set-add seen new-frequency) new-frequency))

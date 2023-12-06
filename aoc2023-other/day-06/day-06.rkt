#lang racket

(require advent-of-code
         threading)

(match-define (list times distances)
  (~> (open-aoc-input (find-session) 2023 6 #:cache #true) port->lines))

;; part 1
(define get-numbers (λ~> string-split (map string->number _) rest))
(define (find-bound race-time dist button-time step)
  (if (< dist (* button-time (- race-time button-time)))
      button-time
      (find-bound race-time dist (+ step button-time) step)))

(define (lower-bound rtime dist)
  (find-bound rtime dist 1 1))
(define (upper-bound rtime dist)
  (find-bound rtime dist rtime -1))

(for/fold ([acc 1])
          ([race-time (in-list (get-numbers times))] [distance (in-list (get-numbers distances))])
  (* acc (add1 (- (upper-bound race-time distance) (lower-bound race-time distance)))))

;; part 2

(define unkern (λ~>> get-numbers (apply ~a) string->number))
(define big-time (unkern times))
(define big-distance (unkern distances))

(add1 (- (upper-bound big-time big-distance) (lower-bound big-time big-distance)))

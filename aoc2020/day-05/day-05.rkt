#lang racket
(require "../../jj-aoc.rkt"
         threading)

(define tickets
  (for/list ([l (in-lines (open-day 5 2020))])
    (~>> l (regexp-match #px"(.{7})(.{3})") rest)))

(define (find-place str min-p max-p l r)
  (if (string=? "" str)
      min-p
      (let ([p-range (/ (add1 (- max-p min-p)) 2)] [c (substring str 0 1)])
        (cond
          [(string=? c l) (find-place (substring str 1) min-p (- max-p p-range) l r)]
          [(string=? c r) (find-place (substring str 1) (+ min-p p-range) max-p l r)]))))

(define (find-row str)
  (find-place str 0 127 "F" "B"))
(define (find-col str)
  (find-place str 0 7 "L" "R"))

(define (ticket-id t)
  (let ([row (find-row (first t))] [col (find-col (second t))]) (+ col (* 8 row))))

;; part 1
(define occupied-seats
  (~>> (for/list ([t (in-list tickets)])
         (ticket-id t))))

(apply max occupied-seats)

;; part 2
(set-first (set-subtract
            (list->set (inclusive-range (apply min occupied-seats) (apply max occupied-seats)))
            (list->set occupied-seats)))

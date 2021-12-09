#lang racket
(require "../../jj-aoc.rkt"
         threading)

(define strs (port->lines (open-day 5 2015)))

;; part 1
(define (at-least-three-vowels? str)
  (~>> str
       (regexp-replace* #px"[^aeiou]" _ "")
       string-length
       (<= 3)))

(define (at-least-one-pair? str)
  (regexp-match? #px"(.)\\1{1,}" str))

(define (no-forbidden-pairs? str)
  (~>> (list "ab" "cd" "pq" "xy")
       (ormap (λ~>> (string-contains? str)))
       not))

(define (nice? str)
  (~>> (list at-least-three-vowels?
             at-least-one-pair?
             no-forbidden-pairs?)
       (andmap (λ (f) (f str)))))

(count nice? strs)

;; part 2
(define (repeating-pair? str)
  (regexp-match? #px"(..).*\\1" str))

(define (symmetry? str)
  (regexp-match? #px"(.).\\1" str))

(define (new-nice? str)
  (~>> (list repeating-pair? symmetry?)
       (andmap (λ (f) (f str)))))

(count new-nice? strs)
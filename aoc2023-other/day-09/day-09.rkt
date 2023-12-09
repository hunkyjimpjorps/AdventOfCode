#lang racket

(require advent-of-code
         threading)

(define histories
  (for/list ([raw-history (in-lines (open-aoc-input (find-session) 2023 9 #:cache #true))])
    (~>> raw-history string-split (map string->number))))

(define (constant? xs) (= 1 (length (remove-duplicates xs))))

(define/match (derivative xs)
  [((list a b)) (list (- b a))]
  [((list* a b _)) (cons (- b a) (derivative (rest xs)))])

(define (extrapolate xs) (if (constant? xs) (car xs) (+ (last xs) (extrapolate (derivative xs)))))

;; part 1
(~>> histories (map extrapolate) (apply +))

;; part 2
(~>> histories (map (λ~> reverse extrapolate)) (apply +))

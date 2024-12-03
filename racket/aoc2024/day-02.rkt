#lang racket

(require advent-of-code)

(define reports
  (for/list ([line (in-lines (open-aoc-input (find-session) 2024 2 #:cache #true))])
    (for/list ([n (in-list (string-split line))])
      (string->number n))))

(define (get-deltas xs)
  (for/list ([a (in-list xs)]
             [b (in-list (rest xs))])
    (- b a)))

(define (safe? deltas)
  (for/or ([ok-values '((1 2 3) (-1 -2 -3))])
    (for/and ([d (in-list deltas)])
      (member d ok-values))))

;; part 1
(for/sum ([report (in-list reports)] #:when (safe? (get-deltas report))) 1)

;; part 2
(for/sum ([report (in-list reports)] ;
          #:when (for/or ([alt (in-combinations report (sub1 (length report)))])
                   (safe? (get-deltas alt))))
         1)

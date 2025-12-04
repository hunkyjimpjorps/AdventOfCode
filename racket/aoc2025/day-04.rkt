#lang racket

(require advent-of-code
         threading
         "utils/posn.rkt")

(define starting-room
  (string->posn-set (fetch-aoc-input (find-session) 2025 4 #:cache #true) (λ (c) (equal? c #\@))))

(define (can-be-removed p room)
  (> 4 (count (λ~> (set-member? room _)) (neighbors-of p in-all-directions))))

;; part 1
(for/sum ([p (in-set starting-room)] #:when (can-be-removed p starting-room)) 1)

;; part 2
(define (keep-removing room [acc 0])
  (define removable-rolls
    (for/set ([p (in-set room)]
              #:when (can-be-removed p room))
      p))
  (if (set-empty? removable-rolls)
      acc
      (keep-removing (set-subtract room removable-rolls) (+ acc (set-count removable-rolls)))))

(keep-removing starting-room)

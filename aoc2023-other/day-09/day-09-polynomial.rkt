#lang racket

(require advent-of-code
         threading
         simple-polynomial/tools)

(define histories
  (for/list ([raw-history (in-lines (open-aoc-input (find-session) 2023 9 #:cache #true))])
    (~>> raw-history 
         string-split 
         (map string->number))))

(for/lists (left right #:result (cons (apply + left) (apply + right)))
           ([history (in-list histories)])
  (define f (interpolate-at-integer-points history))
  (values (f -1) 
          (f (length history))))

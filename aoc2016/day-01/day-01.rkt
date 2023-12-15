#lang racket

(require advent-of-code
         threading)

(struct posn (x y) #:transparent)
(struct dir (x y) #:transparent)

(define/match (left _d)
  [((dir 0 1)) (dir -1 0)]
  [((dir -1 0)) (dir 0 -1)]
  [((dir 0 -1)) (dir 1 0)]
  [((dir 1 0)) (dir 0 1)])

(define/match (right _d)
  [((dir 0 1)) (dir 1 0)]
  [((dir 1 0)) (dir 0 -1)]
  [((dir 0 -1)) (dir -1 0)]
  [((dir -1 0)) (dir 0 1)])

(define/match (go _from _d _dist)
  [((posn x y) (dir dx dy) dist) (posn (+ x (* dx dist)) (+ y (* dy dist)))])

(define input (~> (fetch-aoc-input (find-session) 2016 1 #:cache #true) string-trim (string-split ", ")))

;; part 1
(for/fold ([p (posn 0 0)]
           [d (dir 0 1)]
           #:result (+ (abs (posn-x p)) (abs (posn-y p))))
          ([instruction (in-list input)])
  (displayln (~a p " " d))
  (match instruction
    [(regexp #rx"L(.*)" (list _ n)) (values (go p (left d) (string->number n))
                                            (left d))]
    [(regexp #rx"R(.*)" (list _ n)) (values (go p (right d) (string->number n))
                                            (right d))]))

;; part 2

#lang racket

(provide (struct-out Posn)
         string->posn-grid
         posn-add
         posn-diff
         next-row
         next-col
         in-cardinal-directions
         in-diagonal-directions
         in-all-directions
         neighbors-of)

(struct Posn (x y) #:transparent)

(define (string->posn-grid str [f identity])
  (for*/hash ([(row y) (in-indexed (string-split str))]
              [(col x) (in-indexed row)])
    (values (Posn x y) (f col))))

(define (posn-add a delta)
  (Posn (+ (Posn-x a) (Posn-x delta)) (+ (Posn-y a) (Posn-y delta))))
(define (posn-diff a b)
  (Posn (- (Posn-x a) (Posn-x b)) (- (Posn-y a) (Posn-y b))))

(define/match (next-row _)
  [((Posn x y)) (Posn (add1 x) 0)])
(define/match (next-col _)
  [((Posn x y)) (Posn x (add1 y))])

(define in-cardinal-directions (list (Posn 1 0) (Posn -1 0) (Posn 0 1) (Posn 0 -1)))
(define in-diagonal-directions (list (Posn 1 1) (Posn 1 -1) (Posn -1 -1) (Posn -1 1)))
(define in-all-directions
  (list (Posn -1 0)
        (Posn -1 1)
        (Posn 0 1)
        (Posn 1 1)
        (Posn 1 0)
        (Posn 1 -1)
        (Posn 0 -1)
        (Posn -1 -1)))

(define (neighbors-of p with)
  (map (curry posn-add p) with))

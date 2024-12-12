#lang racket

(provide Posn
         string->posn-grid
         posn-add
         posn-diff
         in-cardinal-directions
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

(define in-cardinal-directions (list (Posn 1 0) (Posn -1 0) (Posn 0 1) (Posn 0 -1)))
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

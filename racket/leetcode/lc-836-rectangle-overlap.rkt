#lang racket
(define (rectangle-area lst)
  (match-define (list x1 y1 x2 y2) lst)
  (* (- x2 x1) (- y2 y1)))

(define/contract (is-rectangle-overlap rec1 rec2)
  (-> (listof exact-integer?) (listof exact-integer?) boolean?)
  (cond [(or (= 0 (rectangle-area rec1))
             (= 0 (rectangle-area rec2))) #false]
        [(not (or ((list-ref rec1 2) . <= . (list-ref rec2 0))
                  ((list-ref rec1 3) . <= . (list-ref rec2 1))
                  ((list-ref rec1 0) . >= . (list-ref rec2 2))
                  ((list-ref rec1 1) . >= . (list-ref rec2 3)))) #true]
        [else #false]))
#lang racket

(require advent-of-code
         threading
         graph
         data/heap)

(struct Posn (x y z) #:transparent)

(define points
  (for/list ([line (in-lines (open-aoc-input (find-session) 2025 8 #:cache #true))])
    (~> line (string-split _ ",") (map string->number _) (apply Posn _))))

(define (dist p1 p2)
  (match-define (Posn x1 y1 z1) p1)
  (match-define (Posn x2 y2 z2) p2)
  (+ (expt (- x1 x2) 2) (expt (- y1 y2) 2) (expt (- z1 z2) 2)))

(define (posn<=? pair1 pair2)
  (<= (dist (first pair1) (second pair1)) (dist (first pair2) (second pair2))))

(define pairs (make-heap posn<=?))
(for ([pair (in-combinations points 2)])
  (heap-add! pairs pair))

;; part 1
(define pt1-wiring-network (unweighted-graph/undirected '()))
(for ([pair (in-heap pairs)]
      [_ (in-range 1000)])
  (add-edge! pt1-wiring-network (first pair) (second pair)))

(~> pt1-wiring-network cc (map length _) (sort >) (take 3) (apply * _))

;; part 2
(time (define pt2-wiring-network (unweighted-graph/undirected '()))
(for/first ([pair (in-heap pairs)]
            #:do [(add-edge! pt2-wiring-network (first pair) (second pair))]
            #:when (and (~> pt2-wiring-network get-vertices length (= 1000))
                        (~> pt2-wiring-network cc first length (= 1000))))
  (* (Posn-x (first pair)) (Posn-x (second pair)))))

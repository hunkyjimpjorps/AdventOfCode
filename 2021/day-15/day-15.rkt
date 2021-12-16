#lang racket
(require "../../jj-aoc.rkt"
         threading
         graph)

(struct Point (x y) #:transparent)

(define data
  (for/fold ([cells (hash)])
            ([row (in-lines (open-day 15 2021))]
             [x (in-naturals)])
    (for/fold ([cells cells])
              ([n (in-string row)]
               [y (in-naturals)])
      (hash-set cells
                (Point x y)
                (~> n string string->number)))))

(define x-max (~>> data hash-keys (map Point-x) (apply max)))
(define y-max (~>> data hash-keys (map Point-y) (apply max)))

(define (neighbors pt d)
  (match-define (Point x y) pt)
  (~>> (list (Point (add1 x) y)
             (Point (sub1 x) y)
             (Point x (add1 y))
             (Point x (sub1 y)))
       (filter (curry hash-has-key? d))))

(define (grid-graph d)
  (weighted-graph/directed
   (for*/list ([coord (in-list (hash-keys d))]
               [neighbor (in-list (neighbors coord d))]
               [weight (in-value (hash-ref d neighbor))])
     (list weight coord neighbor))))

;; part 1
(define (find-path-weight d)
  (define grid (grid-graph d))
  (let-values ([(node-distances _) (dijkstra grid (Point 0 0))])
    (define xm (~>> d hash-keys (map Point-x) (apply max)))
    (define ym (~>> d hash-keys (map Point-y) (apply max)))
    (hash-ref node-distances (Point xm ym))))

(~> data
    find-path-weight
    time)

;; part 2
(define nine-cycle
  (in-cycle (inclusive-range 1 9)))

(define (expand-data data)
  (for/fold ([cells (hash)])
            ([coord (in-list (hash-keys data))])
    (match-define (Point x y) coord)
    (for*/fold ([cells cells])
               ([n (in-range 5)]
                [m (in-range 5)]
                [val (in-value (hash-ref data coord))])
      (hash-set cells
                (Point (+ x (* n (add1 x-max)))
                       (+ y (* m (add1 y-max))))
                (sequence-ref nine-cycle (+ val n m -1))))))

(~> data
    expand-data
    find-path-weight
    time)
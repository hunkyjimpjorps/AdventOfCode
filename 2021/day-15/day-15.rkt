#lang racket
(require "../../jj-aoc.rkt"
         threading
         graph)

(define data
  (for/fold ([cells (hash)])
            ([row (in-lines (open-day 15 2021))]
             [x (in-naturals)])
    (for/fold ([cells cells])
              ([n (in-string row)]
               [y (in-naturals)])
      (hash-set cells
                `(,x ,y)
                (~> n string string->number)))))

(define x-max (~>> data hash-keys (map first) (apply max)))
(define y-max (~>> data hash-keys (map second) (apply max)))

(define (neighbors pt d)
  (match-define (list x y) pt)
  (~>> (list (list (add1 x) y)
             (list (sub1 x) y)
             (list x (add1 y))
             (list x (sub1 y)))
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
  (let-values ([(node-distances _) (dijkstra grid '(0 0))])
    (define xm (~>> d hash-keys (map first) (apply max)))
    (define ym (~>> d hash-keys (map second) (apply max)))
    (hash-ref node-distances (list xm ym))))

(~> data
    find-path-weight
    time)

;; part 2
(define nine-cycle
  (in-cycle (inclusive-range 1 9)))

(define (expand-data data)
  (for/fold ([cells (hash)])
            ([coord (in-list (hash-keys data))])
    (match-define (list x y) coord)
    (for*/fold ([cells cells])
               ([n (in-range 5)]
                [m (in-range 5)]
                [val (in-value (hash-ref data coord))])
      (hash-set cells
                (list (+ x (* n (add1 x-max)))
                      (+ y (* m (add1 y-max))))
                (sequence-ref nine-cycle (+ val n m -1))))))

(~> data
    expand-data
    find-path-weight
    time)
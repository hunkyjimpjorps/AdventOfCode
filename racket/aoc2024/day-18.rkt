#lang racket

(require advent-of-code
         threading
         graph)

(define input
  (~> (fetch-aoc-input (find-session) 2024 18 #:cache #true)
      (string-split "\n")
      (map (λ~> (string-split _ ",") (map string->number _) (apply cons _)) _)))

(define MAX-SIZE 70)

(define (make-empty-graph)
  (~> (for*/list ([x (in-inclusive-range 0 MAX-SIZE)]
                  [y (in-inclusive-range 0 MAX-SIZE)]
                  [delta (in-list (list (cons 0 1) (cons 1 0) (cons -1 0) (cons 0 -1)))]
                  #:do [(define neighbor (cons (+ x (car delta)) (+ y (cdr delta))))]
                  #:when (and (<= 0 (car neighbor) MAX-SIZE) (<= 0 (cdr neighbor) MAX-SIZE)))
        (list (cons x y) neighbor))
      unweighted-graph/undirected))

;; part 1
(define starting-graph (make-empty-graph))
(for ([obstacle (in-list (take input 1024))])
  (remove-vertex! starting-graph obstacle))

(define-values (distances _predecessors) (dijkstra starting-graph (cons 0 0)))
(hash-ref distances (cons 70 70))

;; part 2
(define obstacles (drop input 1024))
(for/first ([obstacle (in-list obstacles)]
            #:do [(remove-vertex! starting-graph obstacle)]
            #:unless (fewest-vertices-path starting-graph (cons 0 0) (cons MAX-SIZE MAX-SIZE)))
  obstacle)

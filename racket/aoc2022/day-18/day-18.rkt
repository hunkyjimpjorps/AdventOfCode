#lang racket

(require advent-of-code
         relation
         threading
         graph)

(define positions (~> (fetch-aoc-input (find-session) 2022 18 #:cache #true) (string-split "\n")))

(struct posn (x y z) #:transparent)

(define cubes
  (for/list ([cube (in-list positions)])
    (match (string-split cube ",")
      [(list (app ->number x) (app ->number y) (app ->number z)) (posn x y z)])))

(define cubes-set (list->set cubes))

(define (neighbors p)
  (match-define (posn x y z) p)
  (for*/list ([dx '(-1 0 1)]
              [dy '(-1 0 1)]
              [dz '(-1 0 1)]
              #:when (= 1 (+ (abs dx) (abs dy) (abs dz))))
    (posn (+ x dx) (+ y dy) (+ z dz))))

;; part 1

(for*/sum ([cube (in-set cubes-set)]
           [neighbor (in-list (neighbors cube))]
           #:unless (set-member? cubes-set neighbor))
  1)

;; part 2
(define max-x (~> cubes (apply max _ #:key posn-x) posn-x (+ 2)))
(define max-y (~> cubes (apply max _ #:key posn-y) posn-y (+ 2)))
(define max-z (~> cubes (apply max _ #:key posn-z) posn-z (+ 2)))

(define air-set
  (for*/set ([x (in-inclusive-range -1 max-x)]
             [y (in-inclusive-range -1 max-y)]
             [z (in-inclusive-range -1 max-z)]
             #:do [(define p (posn x y z))]
             #:unless (set-member? cubes-set p))
    p))

(define air-graph
  (for*/lists (ps #:result (undirected-graph ps))
              ([a (in-set air-set)]
               [neighbor (in-list (neighbors a))]
               #:when (set-member? air-set neighbor))
    (list a neighbor)))

(for*/sum ([air (in-set (~> air-graph cc (sort > #:key length _) car))]
           [neighbor (in-list (neighbors air))]
           #:when (set-member? cubes-set neighbor))
  1)

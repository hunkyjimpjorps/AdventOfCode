#lang racket

(require advent-of-code
         fancy-app
         graph)

(define raw-terrain (fetch-aoc-input (find-session) 2022 12 #:cache #true))
(define special-points (make-hash))

(define terrain-mesh
  (for*/hash ([(row x) (in-indexed (string-split raw-terrain))] [(col y) (in-indexed row)])
    (case col
      [(#\S)
       (hash-set! special-points 'start (cons x y))
       (values (cons x y) 0)]
      [(#\E)
       (hash-set! special-points 'end (cons x y))
       (values (cons x y) 25)]
      [else (values (cons x y) (- (char->integer col) (char->integer #\a)))])))

(define (neighbors p)
  (match-define (cons x y) p)
  (for*/list ([dx (in-list '(-1 0 1))]
              [dy (in-list '(-1 0 1))]
              #:when (= 1 (abs (+ dx dy)))
              #:do [(define p (cons (+ x dx) (+ y dy)))]
              #:when (hash-has-key? terrain-mesh p))
    p))

(define paths
  (directed-graph (for*/list ([p (in-list (hash-keys terrain-mesh))]
                              [neighbor (in-list (neighbors p))]
                              #:unless (> (sub1 (hash-ref terrain-mesh neighbor))
                                          (hash-ref terrain-mesh p)))
                    (list p neighbor))))

;; part 1
(match-define-values (distances _) (dijkstra paths (hash-ref special-points 'start)))
(hash-ref distances (hash-ref special-points 'end))

;; part 2
(for/lists (lengths #:result (apply min lengths))
           ([start (in-list (hash-keys terrain-mesh))] #:when (= 0 (hash-ref terrain-mesh start)))
           (match-define-values (distances _) (dijkstra paths start))
           (hash-ref distances (hash-ref special-points 'end)))

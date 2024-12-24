#lang racket

(require advent-of-code
         graph
         threading)

(define graph
  (~> (for/list (; (in-list (string-split test-input))
                 [line (in-lines (open-aoc-input (find-session) 2024 23 #:cache #true))])
        (string-split line "-"))
      unweighted-graph/undirected))

;; part 1
(~> (for*/set ([v (in-vertices graph)]
               #:when (string-prefix? v "t")
               [rest-of-clique (in-combinations (get-neighbors graph v) 2)]
               #:when (apply has-edge? graph rest-of-clique))
      (set (sort (cons v rest-of-clique) string<=?)))
    set-count)

;; part 2
(define (bron-kerbosch acc P [R (set)] [X (set)])
  (cond
    [(and (empty? P) (set-empty? X)) (cons R acc)]
    [(empty? P) acc]
    [else
     (match-define (list* vertex remaining) P)
     (~> acc
         (bron-kerbosch remaining R (set-add X vertex))
         (bron-kerbosch (filter (λ (q) (has-edge? graph vertex q)) P)
                        (set-add R vertex)
                        (set-intersect X (list->set (get-neighbors graph vertex)))))]))

(~> (bron-kerbosch '() (get-vertices graph))
    set->list
    (argmax set-count _)
    set->list
    (sort string<=?)
    (string-join ","))

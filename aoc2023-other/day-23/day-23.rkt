#lang racket

(require advent-of-code
         threading
         graph)

(define input (fetch-aoc-input (find-session) 2023 23 #:cache #true))
(define trails
  (for*/hash ([(row r) (in-indexed (string-split input "\n"))]
              [(col c) (in-indexed row)]
              #:when (not (equal? col #\#)))
    (values (cons (add1 r) (add1 c))
            (match col
              [#\. 'trail]
              [_ 'slope]))))

(define max-row (~> input (string-split "\n") length))

(define start (findf (λ (p) (= (car p) 1)) (hash-keys trails)))
(define end (findf (λ (p) (= (car p) max-row)) (hash-keys trails)))

(define (get-neighbors posn type)
  (match-define (cons r c) posn)
  (match type
    ['trail
     (~> (list (cons (add1 r) c) (cons (sub1 r) c) (cons r (add1 c)) (cons r (sub1 c)))
         (filter (curry hash-has-key? trails) _)
         list->set)]
    ['junction (~> (set (cons (add1 r) c) (cons r (add1 c))))]))

(define junction-points
  (for/set ([(k v) (in-hash trails)] #:when (and (equal? v 'trail)
                                                 (not (= (set-count (get-neighbors k v)) 2))))
    k))

(define trails-with-junctions
  (for/hash ([k (in-hash-keys trails)])
    (cond
      [(set-member? junction-points k) (values k 'junction)]
      [else (values k 'trail)])))

(define (walk-to-next-junction start current [length 1] [seen (set start)])
  (define next (~> current (get-neighbors _ 'trail) (set-subtract seen) set-first))
  (cond
    [(equal? (hash-ref trails-with-junctions next) 'junction) (list (- (add1 length)) start next)]
    [else (walk-to-next-junction start next (add1 length) (set-add seen current))]))

(define routes-to-junctions
  (for*/list ([j (in-set junction-points)]
              [neighbor (in-set (get-neighbors j 'junction))]
              #:when (hash-has-key? trails neighbor))
    (walk-to-next-junction j neighbor)))

;; part 1 -- using graph library for Bellman-Ford on negative weighted graph
(define slippery-trail (weighted-graph/directed routes-to-junctions))
(match-define-values (distances _) (bellman-ford slippery-trail start))
(- (hash-ref distances end))

;; part 2 -- rolling my own DFS
(define routes-to-junctions-with-traction
  (for/fold ([trails (hash)]) ([route (in-list routes-to-junctions)])
    (match-define (list (app - weight) from to) route)
    (~> trails
        (hash-update _ from (curry cons (cons to weight)) '())
        (hash-update _ to (curry cons (cons from weight)) '()))))

(define (dfs g from to [acc 0] [seen (set from)])
  (cond
    [(equal? from to) acc]
    [else
     (define choices (~> (hash-ref g from) (filter (λ (path) (not (set-member? seen (car path)))) _)))
     (if (empty? choices) 0
         (for/fold ([best acc])
                   ([path (in-list choices)]
                    #:do [(match-define (cons next dist) path)])
           (max best (dfs g next to (+ acc dist) (set-add seen next)))))]))

(dfs routes-to-junctions-with-traction start end)
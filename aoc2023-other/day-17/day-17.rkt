#lang racket

(require advent-of-code
         threading)

(struct posn (r c) #:transparent)
(struct to (posn dir) #:transparent)
(struct edge (from to dir) #:transparent)

(define input
  "2413432311323
3215453535623
3255245654254
3446585845452
4546657867536
1438598798454
4457876987766
3637877979653
4654967986887
4564679986453
1224686865563
2546548887735
4322674655533")

(define grid
  (for*/hash ([(row r) (in-indexed (in-list (string-split input "\n")))]
              [(col c) (in-indexed (in-string row))])
    (values (posn r c) (~> col string string->number))))

(define grid-nodes (hash-keys grid))
(match-define (posn rmax cmax) (argmax (λ (p) (+ (posn-r p) (posn-c p))) grid-nodes))

(define/match (find-edge-cost e prev-two)
  [((edge _ _ d) (list d d)) 1e10]
  [(_ _) (hash-ref edges e)])

(define (find-node-cost p)
  (match-define (posn r c) p)
  (+ (- rmax r) (- cmax c)))

(define (neighbors p)
  (match-define (posn r c) p)
  (~>> (list (to (posn (sub1 r) c) 'north)
             (to (posn (add1 r) c) 'south)
             (to (posn r (add1 c)) 'east)
             (to (posn r (sub1 c)) 'west))
       (filter (λ (p) (hash-has-key? grid (to-posn p))))))

(define edges
  (for*/hash ([(k v) (in-hash grid)] [neighbor (in-list (neighbors k))])
    (values (edge k (to-posn neighbor) (to-dir neighbor)) v)))

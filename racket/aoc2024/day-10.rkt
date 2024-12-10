#lang racket

(require advent-of-code
         threading
         racket/hash)

(struct Posn (x y) #:transparent)
(define (go a delta)
  (Posn (+ (Posn-x a) (Posn-x delta)) (+ (Posn-y a) (Posn-y delta))))
(define in-cardinal-directions (list (Posn 1 0) (Posn -1 0) (Posn 0 1) (Posn 0 -1)))
(define (neighbors-of p with)
  (map (curry go p) with))

(define input (fetch-aoc-input (find-session) 2024 10 #:cache #true))

(define GRID
  (for*/hash ([(row y) (in-indexed (string-split input))]
              [(col x) (in-indexed row)])
    (values (Posn x y) (~> col string string->number))))

(define (look-for-summit current [summits '()])
  (match (hash-ref GRID current)
    [9 (cons current summits)]
    [elev
     (for/fold ([acc summits]) ([neighbor (neighbors-of current in-cardinal-directions)])
       (if (equal? (add1 elev) (hash-ref GRID neighbor #f))
           (look-for-summit neighbor acc)
           acc))]))

(define (rate-trails using)
  (define trailheads (~> GRID (hash-filter (λ (_ v) (= v 0))) hash-keys))
  (for/sum ([trailhead trailheads]) (~> trailhead look-for-summit using)))

;; part 1
(rate-trails (λ~> list->set set-count))

;; part 2
(rate-trails length)

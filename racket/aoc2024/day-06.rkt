#lang racket

(require racket/hash
         advent-of-code
         threading)

(struct posn (r c) #:transparent)

(define/match (rotate _dir)
  [('up) 'right]
  [('right) 'down]
  [('down) 'left]
  [('left) 'up])

(define/match (towards _dir)
  [('up) (posn -1 0)]
  [('right) (posn 0 1)]
  [('down) (posn 1 0)]
  [('left) (posn 0 -1)])

(define/match (go _p _dir)
  [((posn x y) (posn dx dy)) (posn (+ x dx) (+ y dy))])

(define input (open-aoc-input (find-session) 2024 6 #:cache #t))

(define (parse-cell ch)
  (case ch
    [(#\#) 'obstruction]
    [(#\.) 'floor]
    [(#\^) 'start]))

(define starting-grid
  (for*/hash ([(row r) (in-indexed (in-lines input))]
              [(col c) (in-indexed row)])
    (values (posn r c) (parse-cell col))))

(define start (~> starting-grid (hash-filter (λ (_ v) (equal? v 'start))) hash-keys first))

;; part 1
(define (next-step [tile start] [dir 'up] [grid starting-grid])
  (define ahead (go tile (towards dir)))
  (match (hash-ref grid ahead #f)
    [(or 'floor 'start 'visited) (next-step ahead dir (hash-set grid tile 'visited))]
    ['obstruction (next-step tile (rotate dir) grid)]
    [#f (~> grid (hash-set tile 'visited) (hash-filter (λ (_ v) (equal? v 'visited))))]))

(~> (next-step) hash-count)

;; part 2
(define (causes-loop? grid [tile start] [dir 'up] [seen (set)])
  (cond
    [(set-member? seen (cons tile dir)) #t]
    [else
     (define ahead (go tile (towards dir)))
     (match (hash-ref grid ahead #f)
       [(or 'floor 'start) (causes-loop? grid ahead dir (set-add seen (cons tile dir)))]
       ['obstruction (causes-loop? grid tile (rotate dir) seen)]
       [#f #f])]))

(define candidates (~> (next-step) hash-keys))

(for/sum ([candidate (in-list candidates)] ;
          #:do [(define tampered-grid (hash-set starting-grid candidate 'obstruction))]
          #:when (causes-loop? tampered-grid))
         1)

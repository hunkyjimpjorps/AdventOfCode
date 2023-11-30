#lang racket

(require threading
         "../../jj-aoc.rkt")

(define sea-floor-data
  (for/vector ([l (in-lines (open-day 9))] #:unless (equal? l ""))
    (~>> l string->list (map (λ~>> ~a string->number)) list->vector)))

(define max-rows (vector-length sea-floor-data))
(define max-cols (vector-length (vector-ref sea-floor-data 0)))
(define-values (min-rows min-cols) (values 0 0))

(define (vector2d-ref vec coord)
  (match-define `(,r ,c) coord)
  (~> vec (vector-ref r) (vector-ref c)))

(define (adjacent coords)
  (match-define `(,r ,c) coords)
  `((,(add1 r) ,c) (,(sub1 r) ,c) (,r ,(add1 c)) (,r ,(sub1 c))))

(define (valid-coordinate coord)
  (match-define `(,r ,c) coord)
  (and (>= r min-rows) (< r max-rows) (>= c min-cols) (< c max-cols)))

;; part 1
(define (lowest-point? vec coord)
  (for*/and ([neighbor (in-list (adjacent coord))] #:when (valid-coordinate neighbor))
    (< (vector2d-ref vec coord) (vector2d-ref vec neighbor))))

(for*/sum ([r (in-range min-rows max-rows)] [c (in-range min-cols max-cols)]
                                            [coord (in-value `(,r ,c))]
                                            #:when (lowest-point? sea-floor-data coord))
          (add1 (vector2d-ref sea-floor-data coord)))

;; part 2
;; all the basins are bordered by the edges or by ridges of elevation 9,
;; so it's not really necessary to start at a low point
(define walked (make-hash))

(define (walkable? vec coord)
  (and (< (vector2d-ref vec coord) 9) (not (hash-has-key? walked coord))))

(define (walk-the-basin vec coord)
  (cond
    [(walkable? vec coord)
     (hash-set! walked coord 'visited)
     (add1 (for/sum [(neighbor (in-list (adjacent coord))) #:when (valid-coordinate neighbor)]
                    (walk-the-basin vec neighbor)))]
    [else 0]))

(define basins
  (for*/list ([r (in-range min-rows max-rows)]
              [c (in-range min-cols max-cols)]
              [coord (in-value `(,r ,c))]
              #:when (walkable? sea-floor-data coord))
    (walk-the-basin sea-floor-data coord)))

(~> basins (sort >) (take 3) (apply * _))

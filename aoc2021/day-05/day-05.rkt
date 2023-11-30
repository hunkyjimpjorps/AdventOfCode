#lang racket
(require advent-of-code
         threading)

(define data
  (for/list ([l (in-lines (open-aoc-input (find-session) 2021 5 #:cache (string->path "./cache")))])
    (~> l (string-replace " -> " ",") (string-split ",") (map string->number _))))

(define (trace-line! x y vec)
  (define linear-coord (+ y (* 1000 x)))
  (vector-set! vec linear-coord (+ 1 (vector-ref vec linear-coord))))

(define/match (orthogonal? coord-pair)
  [((or (list n _ n _) (list _ n _ n))) #t]
  [(_) #f])

(define-values (orthogonal-lines diagonal-lines) (partition orthogonal? data))

(define (dir a b)
  (if (< a b) 1 -1))

(define (trace-orthogonal! coord-pairs tracer result)
  (for ([coord-pair (in-list coord-pairs)])
    (match coord-pair
      [(list x y1 x y2)
       (for ([y (inclusive-range y1 y2 (dir y1 y2))])
         (tracer x y result))]
      [(list x1 y x2 y)
       (for ([x (inclusive-range x1 x2 (dir x1 x2))])
         (tracer x y result))])))

(define (trace-diagonal! coord-pairs tracer result)
  (for ([coord-pair (in-list coord-pairs)])
    (match-define (list x1 y1 x2 y2) coord-pair)
    (for ([x (inclusive-range x1 x2 (dir x1 x2))] [y (inclusive-range y1 y2 (dir y1 y2))])
      (tracer x y result))))

;; part 1
(define sea-floor (make-vector 1000000))
(trace-orthogonal! orthogonal-lines trace-line! sea-floor)
(vector-count (curry <= 2) sea-floor)

;; part 2
;; since the orthogonal lines have already been traced,
;; all I need to do is add the diagonal ones to the existing vector
(trace-diagonal! diagonal-lines trace-line! sea-floor)
(vector-count (curry <= 2) sea-floor)

;; alternate sparse representation
(define (trace-line-sparse! x y dict)
  (hash-update! dict (list x y) (curry + 1) 0))

(define sea-floor-dict (make-hash))
(trace-orthogonal! orthogonal-lines trace-line-sparse! sea-floor-dict)
(count (curry <= 2) (hash-values sea-floor-dict))
(trace-diagonal! diagonal-lines trace-line-sparse! sea-floor-dict)
(count (curry <= 2) (hash-values sea-floor-dict))

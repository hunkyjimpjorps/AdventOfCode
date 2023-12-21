#lang racket

(require advent-of-code
         threading
         simple-polynomial
         racket/hash)

(define input (fetch-aoc-input (find-session) 2023 21 #:cache #true))

(define initial-garden
  (~> (for*/list ([(row r) (in-indexed (string-split input "\n"))]
                  [(col c) (in-indexed row)]
                  #:unless (equal? col #\#))
        (cons (cons r c) (if (equal? col #\S) 'on 'off)))
      make-hash))

(define (neighbors p)
  (match-define (cons r c) p)
  (list (cons (add1 r) c) (cons (sub1 r) c) (cons r (add1 c)) (cons r (sub1 c))))

(define (make-n-steps garden n)
  (define g (hash-copy garden))
  (define (make-one-step)
    (define update (make-hash))
    (for ([(cons state) (in-hash g)] #:when (equal? state 'on))
      (hash-set! update cons 'off)
      (for ([neighbor (in-list (neighbors cons))] #:when (hash-has-key? g neighbor))
        (hash-set! update neighbor 'on)))
    (hash-union! g update #:combine/key (λ (_k _v v) v)))
  (for/fold ([_ void] #:result (~>> g hash-values (count (curry equal? 'on)))) ([i (in-range n)])
    (displayln i)
    (make-one-step)))

;; part 1
(make-n-steps initial-garden 64)

;; part 2
;; the growth of the steps pattern is regular and quadratic
;; the rock pattern has aisles in it that allow the steps pattern to expand freely
;; such that it will cross from one side to another in X steps
;; where X is the height/width of the repeated section

(define grid-size (~> input (string-split "\n") length))
(define half-size (/ (sub1 grid-size) 2))

(define expanded-garden
  (~> (for*/list (#:do [(define rows (string-split input "\n"))]
                  #:do [(define height (length rows))]
                  [(row r) (in-indexed rows)]
                  #:do [(define width (string-length row))]
                  [(col c) (in-indexed row)]
                  #:unless (equal? col #\#)
                  [n (in-inclusive-range -3 3)]
                  [m (in-inclusive-range -3 3)])

        (cons (cons (+ r (* n height)) (+ c (* m width)))
              (if (and (= n m 0) (equal? col #\S)) 'on 'off)))
      make-hash))

(define fitting-points
  (for/list ([n (in-range 3)] #:do [(define size (+ half-size (* n grid-size)))])
    (cons n (make-n-steps expanded-garden size))))

(define end-cycle 26501365)
(define x (/ (- end-cycle half-size) grid-size))

((points->polynomial fitting-points) x)
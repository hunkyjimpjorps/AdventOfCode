#lang racket

(require advent-of-code)

(define raw-grid (fetch-aoc-input (find-session) 2020 11))

(define/match (parse _)
  [(#\L) 'empty]
  [(#\#) 'occupied]
  [(#\.) 'floor])

(define seat-grid
  (for*/hash ([(row r) (in-indexed (in-list (string-split raw-grid)))]
              [(col c) (in-indexed (in-string row))])
    (values (cons r c) (parse col))))

(define (next-seat-state seat state h rule [max-occupy 4])
  (define neighbor-states (rule seat h))
  (match* (state (count (curry eq? 'occupied) neighbor-states))
    [('empty 0) 'occupied]
    [('occupied n)
     #:when (>= n max-occupy)
     'empty]
    [(_ _) state]))

(define (stabilize h [i 1] #:rule rule #:max-occupy [max-occupy 4])
  (define h*
    (for/hash ([(seat state) (in-hash h)])
      (cond
        [(eq? state 'floor) (values seat state)]
        [else (values seat (next-seat-state seat state h rule max-occupy))])))
  (if (equal? h h*)
      (count (curry equal? 'occupied) (hash-values h))
      (stabilize h* (add1 i) #:rule rule #:max-occupy max-occupy)))

;; part 1
(define (find-nearest-neighbors p h)
  (match-define (cons r c) p)
  (for*/list ([r* (in-inclusive-range (sub1 r) (add1 r))]
              [c* (in-inclusive-range (sub1 c) (add1 c))]
              [p* (in-value (cons r* c*))]
              #:unless (equal? p p*))
    (hash-ref h p* 'out-of-bounds)))

(stabilize seat-grid #:rule find-nearest-neighbors)

;; part 2
(define (find-visible-neighbors p h)
  (match-define (cons r c) p)
  (define directions
    (for*/list ([dr '(-1 0 1)] [dc '(-1 0 1)] #:unless (= 0 dr dc))
      (cons dr dc)))
  (for/list ([dir (in-list directions)] #:do [(match-define (cons dr dc) dir)])
    (for*/first ([i (in-naturals 1)]
                 #:do [(define p* (cons (+ r (* i dr)) (+ c (* i dc))))
                       (define state (hash-ref h p* 'out-of-bounds))]
                 #:unless (equal? state 'floor))
      state)))

(stabilize seat-grid #:rule find-visible-neighbors #:max-occupy 5)

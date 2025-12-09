#lang racket

(require advent-of-code
         threading
         data/heap)

(struct Posn (x y z))
(struct Room (boxes circuits seen))

(define points
  (for/list ([line (in-lines (open-aoc-input (find-session) 2025 8 #:cache #true))])
    (~> line (string-split _ ",") (map string->number _) (apply Posn _))))

(define (dist p1 p2)
  (match-define (Posn x1 y1 z1) p1)
  (match-define (Posn x2 y2 z2) p2)
  (+ (expt (- x1 x2) 2) (expt (- y1 y2) 2) (expt (- z1 z2) 2)))

(define (posn<=? pair1 pair2)
  (<= (dist (first pair1) (second pair1)) (dist (first pair2) (second pair2))))

(define pairs (make-heap posn<=?))
(for ([pair (in-combinations points 2)])
  (heap-add! pairs pair))

(define starting-room
  (Room (for/hash ([point (in-list points)]
                   [index (in-naturals)])
          (values point index))
        (for/hash ([point (in-list points)]
                   [index (in-naturals)])
          (values index (set point)))
        (set)))

(define (unify room pair)
  (match-define (Room boxes circuits seen) room)
  (match-define (list point-a point-b) pair)
  (match* ((hash-ref boxes point-a) (hash-ref boxes point-b))
    [(circuit-a circuit-a) (Room boxes circuits seen)]
    [(circuit-a circuit-b)
     (define boxes-a (hash-ref circuits circuit-a))
     (define boxes-b (hash-ref circuits circuit-b))
     (Room (for/fold ([acc boxes]) ([box (in-set boxes-b)])
             (hash-set acc box circuit-a))
           (~> circuits (hash-remove circuit-b) (hash-set circuit-a (set-union boxes-a boxes-b)))
           (~> seen (set-remove point-a) (set-remove point-b)))]))

;; part 1
(for/fold ([room starting-room]
           #:result
           (~> room Room-circuits (hash-values) (map set-count _) (sort >) (take 3) (apply * _)))
          ([pair (in-heap pairs)]
           [_ (in-range 1000)])
  (unify room pair))

;; part 2
(for/fold ([room starting-room]
           [last-pair #f]
           #:result (~>> last-pair (map Posn-x) (apply *)))
          ([pair (in-heap pairs)]
           #:do [(define new-room (unify room pair))]
           #:break (and (set-empty? (Room-seen new-room))
                        (= 1 (length (hash-values (Room-circuits room))))))
  (values new-room pair))

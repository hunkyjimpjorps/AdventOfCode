#lang racket

(require advent-of-code
         threading
         struct-update)

(struct Robot (posn vel))
(struct Posn (x y) #:transparent)
(define-struct-updaters Robot)
(define-struct-updaters Posn)

(define H-SIZE 101)
(define V-SIZE 103)
(define h-mid (quotient H-SIZE 2))
(define v-mid (quotient V-SIZE 2))

(define/match (go-wrap _a _delta)
  [((Posn ax ay) (Posn dx dy)) (Posn (modulo (+ ax dx) H-SIZE) (modulo (+ ay dy) V-SIZE))])

(define ROBOTS
  (for/list ([line (in-lines (open-aoc-input (find-session) 2024 14 #:cache #true))])
    (match-define (list x y vx vy)
      (~>> line
           (regexp-match* #px"p=(\\d+),(\\d+) v=(-?\\d+),(-?\\d+)" #:match-select rest)
           flatten
           (map string->number)))
    (Robot (Posn x y) (Posn vx vy))))

(define/match (move-to-time robot t)
  [((Robot posn (Posn vx vy)) _) (Robot-posn-set robot (go-wrap posn (Posn (* t vx) (* t vy))))])

(define (in-quadrant? robot)
  (match-define (Robot (Posn x y) _) robot)
  (not (or (= x h-mid) (= y v-mid))))

(define (classify-quadrant robot)
  (match-define (Robot (Posn x y) _) robot)
  (cond
    [(and (> x h-mid) (< y v-mid)) 1]
    [(and (< x h-mid) (< y v-mid)) 2]
    [(and (> x h-mid) (> y v-mid)) 3]
    [(and (< x h-mid) (> y v-mid)) 4]))

;; part 1

(~>> ROBOTS
     (map (λ~> (move-to-time _ 100)))
     (filter in-quadrant?)
     (group-by classify-quadrant)
     (map length)
     (apply *))

;; part 2

(define (find-all-drones-alone robots)
  (~>> robots (map Robot-posn) (group-by values) (findf (λ~> length (_ . > . 1))) not))

(for/first ([i (in-naturals 1)]
            #:when (~>> ROBOTS (map (λ~> (move-to-time _ i))) find-all-drones-alone))
  i)

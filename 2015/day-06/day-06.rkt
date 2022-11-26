#lang racket
(require "../../jj-aoc.rkt"
         threading)

(struct instruction (todo x1 y1 x2 y2) #:transparent)

(define (make-instruction lst)
  (apply instruction (string->symbol (first lst)) (map string->number (rest lst))))

(define instructions
  (for/list ([l (in-lines (open-day 6 2015))])
    (~>> l
         (regexp-match
          #px"(turn on|toggle|turn off) (\\d{1,3}),(\\d{1,3}) through (\\d{1,3}),(\\d{1,3})")
         rest
         make-instruction)))

(define (vector2d-modify! vec x y f)
  (define pos (+ x (* 1000 y)))
  (vector-set! vec pos (f (vector-ref vec pos))))

;; part 1
(define (todo inst)
  (match (instruction-todo inst)
    ['|turn on| (λ _ #true)]
    ['|turn off| (λ _ #false)]
    ['|toggle| not]))

(define (modify-light-grid inst light-grid using)
  (for ([x (inclusive-range (instruction-x1 inst) (instruction-x2 inst))])
    (for ([y (inclusive-range (instruction-y1 inst) (instruction-y2 inst))])
      (vector2d-modify! light-grid x y (using inst)))))

(define light-grid (make-vector (* 1000 1000) #false))
(for ([i (in-list instructions)])
  (modify-light-grid i light-grid todo))
(vector-count identity light-grid)

;; part 2
(define (todo-dimmer inst)
  (match (instruction-todo inst)
    ['|turn on| add1]
    ['|turn off| (λ (x) (max 0 (sub1 x)))]
    ['|toggle| (curry + 2)]))

(define dimmable-grid (make-vector (* 1000 1000) 0))
(for ([i (in-list instructions)])
  (modify-light-grid i dimmable-grid todo-dimmer))
(apply + (vector->list dimmable-grid))

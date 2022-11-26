#lang racket
(require "../../jj-aoc.rkt"
         threading)

(define-values (x-min x-max y-min y-max)
  (~> (open-day 17 2021)
      port->string
      (regexp-match #px"target area: x=(.*)\\.\\.(.*), y=(.*)\\.\\.(.*)\n" _)
      rest
      (map string->number _)
      (apply values _)))

(define (hit? x y)
  (and (x . >= . x-min) (x . <= . x-max) (y . >= . y-min) (y . <= . y-max)))

(define (miss? x y)
  (or (y . < . y-min) (x . > . x-max)))

(define (drag dx i)
  (max (- dx i) 0))
(define (gravity dy i)
  (- dy i))

(define (find-trajectory-apex dx dy)
  (for/fold ([x 0] [y 0] [y-apex 0] [result #f] #:result (list y-apex result))
            ([i (in-naturals)] #:break result)
    (cond
      [(hit? x y) (values dx dy y-apex 'hit)]
      [(miss? x y) (values x y 'miss 'miss)]
      [else (values (+ x (drag dx i)) (+ y (gravity dy i)) (if (y . > . y-apex) y y-apex) #f)])))

(define on-target
  (for*/list ([dx (in-inclusive-range 1 x-max)]
              [dy (in-inclusive-range y-min (abs (* 2 y-max)))]
              [velocity (in-value (find-trajectory-apex dx dy))]
              #:when (equal? (second velocity) 'hit))
    (list dx dy (first velocity))))

;; part 1
(~>> on-target (argmax third) third)

;; part 2
(length on-target)

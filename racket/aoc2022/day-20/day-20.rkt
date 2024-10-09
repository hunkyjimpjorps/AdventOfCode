#lang racket
(require advent-of-code
         threading)

(define data (port->list read (open-aoc-input (find-session) 2022 20 #:cache #true)))

(define gps-lst data)
(define gps-len (length gps-lst))
(define gps-indexed (map cons (inclusive-range 1 gps-len) gps-lst))

(define (mix pt data)
  (match-define (list left ... (== pt) right ...) data)
  (define start (index-of data pt))
  (define move-by (modulo (cdr pt) (sub1 gps-len)))
  (cond
    [(= 0 move-by) data]
    [(<= move-by (length right))
     (match-define-values (new-left new-right)
       (split-at (append left right) (modulo (+ move-by start) (sub1 gps-len))))
     (append new-left (list pt) new-right)]
    [else
     (match-define-values (new-left new-right)
       (split-at (append left right) (modulo (+ move-by start) (sub1 gps-len))))
     (append new-left (list pt) new-right)]))

(define (mix-gps data original)
  (for/fold ([pts data]) ([pt original])
    (mix pt pts)))

(define (cycle-mixed-gps mixed)
  (define lst (map cdr mixed))
  (in-sequences (drop lst (index-of lst 0)) (in-cycle lst)))

(define (calculate-answer seq)
  (for/sum ([id '(1000 2000 3000)]) (sequence-ref seq id)))

;; part 1
(~> gps-indexed (mix-gps _ gps-indexed) cycle-mixed-gps calculate-answer)

;; part 2
(define encrypted-gps-indexed
  (for/list ([pt (in-list gps-indexed)] #:do [(match-define (cons i v) pt)])
    (cons i (* 811589153 v))))

(~>> encrypted-gps-indexed
     ((λ (data) (foldr (λ (_ pts) (mix-gps pts data)) data (range 10))))
     cycle-mixed-gps
     calculate-answer)

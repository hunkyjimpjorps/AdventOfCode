#lang racket
(require advent-of-code)

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
  (in-sequences (drop mixed (index-of mixed 0)) (in-cycle mixed)))
(define (calculate-answer mix)
  (for/sum ([id '(1000 2000 3000)]) (sequence-ref mix id)))

;; part 1
(define part1-mix (cycle-mixed-gps (map cdr (mix-gps gps-indexed gps-indexed))))
(calculate-answer part1-mix)

;; part 2
(define encrypted-gps-indexed
  (for/list ([pt (in-list gps-indexed)] #:do [(match-define (cons i v) pt)])
    (cons i (* 811589153 v))))

(define part2-mix
  (cycle-mixed-gps (map cdr
                        (for/fold ([pts encrypted-gps-indexed]) ([_ (in-range 10)])
                          (mix-gps pts encrypted-gps-indexed)))))
(calculate-answer part2-mix)

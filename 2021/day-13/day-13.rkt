#lang racket
(require "../../jj-aoc.rkt"
         threading)

(define (make-pt x y)
  (hash 'x x 'y y))
(struct fold (dir loc) #:transparent)
(define (make-fold dir loc)
  (fold (string->symbol dir)
        (string->number loc)))

(define data (port->lines (open-day 13 2021)))
(define-values (points-list folds-list) (splitf-at data (λ~> (equal? "") not)))

(define pts
  (for/set ([p (in-list points-list)])
    (~> p
      (string-split ",")
      (map string->number _)
      (apply make-pt _))))

(define folds
  (for/list ([f (in-list (rest folds-list))])
    (~>> f
         (regexp-match #px"fold along (.)=(.*)")
         rest
         (apply make-fold))))

(define (fold-over f pts)
  (define dir (fold-dir f))
  (define loc (fold-loc f))
  (for/set ([p (in-set pts)])
    (cond
      [(> (hash-ref p dir) loc) (hash-update p dir (λ (l) (- (* 2 loc) l)))]
      [else p])))

;; part 1
(~>> pts
     (fold-over (first folds))
     set-count)

;; part 2
(define final-fold
  (for/fold ([p pts])
            ([f (in-list folds)])
    (fold-over f p)))

(for/list ([y (in-range 6)])
  (~>> (for/list ([x (in-range 39)])
         (if (set-member? final-fold (hash 'x x 'y y))
             #\█
             #\space))
       (apply string)
       println))

#|
for this data set, the result looks like
" ██  █  █  ██   ██  ███   ██   ██  █  █"
"█  █ █  █ █  █ █  █ █  █ █  █ █  █ █  █"
"█  █ ████ █    █    █  █ █    █  █ █  █"
"████ █  █ █ ██ █    ███  █ ██ ████ █  █"
"█  █ █  █ █  █ █  █ █    █  █ █  █ █  █"
"█  █ █  █  ███  ██  █     ███ █  █  ██ "
|#
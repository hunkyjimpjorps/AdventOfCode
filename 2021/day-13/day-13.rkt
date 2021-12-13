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
  (for/set ([pt (in-list points-list)])
    (~> pt
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
  (for/set ([pt (in-set pts)])
    (cond
      [(> (hash-ref pt dir) loc) (hash-update pt dir (λ (l) (- (* 2 loc) l)))]
      [else pt])))

;; part 1
(~>> pts
     (fold-over (first folds))
     set-count)

;; part 2
(define final-pts
  (for/fold ([pt pts])
            ([f (in-list folds)])
    (fold-over f pt)))

(define (max-dim pts dim)
  (~>> (for/list ([pt (in-set pts)])
         (hash-ref pt dim))
       (apply max)))

(for ([y (in-inclusive-range 0 (max-dim final-pts 'y))])
  (~>> (for/list ([x (in-inclusive-range 0 (max-dim final-pts 'x))])
         (if (set-member? final-pts (hash 'x x 'y y))
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
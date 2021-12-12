#lang racket
(require "../../jj-aoc.rkt"
         threading)

(define path-pairs
  (for/list ([l (in-lines (open-day 12 2021))])
    (match (string-split l "-")
      [(list start end) (cons start end)])))

(define edges-hash (make-hash))

(for ([pair (in-list path-pairs)])
  (match-define (cons start end) pair)
  (hash-update! edges-hash
                start
                (curry cons end)
                '())
  (hash-update! edges-hash
                end
                (curry cons start)
                '()))

;; part 1
(define (backtracking-allowed? next prevs)
  (and (equal? (string-downcase next) next)
       (member next prevs)))

(define (look-for-next-cave
         [path-list '("start")]
         #:two-visits? [visit-used-up? #t])
  (define current-cave (car path-list))
  (cond
    [(equal? current-cave "end") (list path-list)]
    [else
     (~>> (for/list ([next-path (in-list (hash-ref edges-hash current-cave null))]
                     #:unless (equal? next-path "start")
                     #:when (not (and (backtracking-allowed? next-path path-list)
                                      visit-used-up?)))
            (look-for-next-cave
             (cons next-path path-list)
             #:two-visits? (or (backtracking-allowed? next-path path-list)
                               visit-used-up?)))
          (apply append))]))

(~> (look-for-next-cave)
  length
  time)

;; part 2
(~> (look-for-next-cave #:two-visits? #f)
  length
  time)
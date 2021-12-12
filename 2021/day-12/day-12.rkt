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
(define (backtracking-disallowed? next prevs)
  (and (equal? (string-downcase next) next)
       (member next prevs)))

(define (look-for-next-cave
         [path-list '("start")]
         #:only-one-visit? [visit-used-up? #t])
  (define current-cave (car path-list))
  (cond
    [(equal? current-cave "end") (list path-list)]
    [else
     (~>> (for/list ([next-path (in-list (hash-ref edges-hash current-cave null))]
                     #:when (and (not (equal? next-path "start"))
                                 (not (and (backtracking-disallowed? next-path path-list)
                                           visit-used-up?))))
            (look-for-next-cave
             (cons next-path path-list)
             #:only-one-visit? (or (backtracking-disallowed? next-path path-list)
                                   visit-used-up?)))
          (apply append))]))

(~> (look-for-next-cave)
  length
  time)

;; part 2
(~> (look-for-next-cave #:only-one-visit? #f)
  length)
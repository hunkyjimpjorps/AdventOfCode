#lang racket
(require "../../jj-aoc.rkt"
         threading)

(struct step (instruction xs ys zs) #:transparent)

;; part 1
(define (clamped-range nmin nmax)
  (in-inclusive-range (max (string->number nmin) -50)
                      (min (string->number nmax) 50)))

(define steps
  (for/list ([l (in-list (~> (open-day 22 2021) (port->lines)))])
    (~>> l
         (regexp-match #px"(.+) x=(-?\\d+)..(-?\\d+),y=(-?\\d+)..(-?\\d+),z=(-?\\d+)..(-?\\d+)")
         rest
         (match _ [(list direction xmin xmax ymin ymax zmin zmax)
                   (step (string->symbol direction)
                         (clamped-range xmin xmax)
                         (clamped-range ymin ymax)
                         (clamped-range zmin zmax))]))))

(~> (for*/fold ([cubes (hash)])
               ([s (in-list steps)]
                [to (in-value (step-instruction s))]
                [x (step-xs s)]
                [y (step-ys s)]
                [z (step-zs s)])
      (hash-set cubes (list x y z) to))
    hash-values
    (count (curry equal? 'on) _))


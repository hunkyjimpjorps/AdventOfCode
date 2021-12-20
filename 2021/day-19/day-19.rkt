#lang racket
(require "../../jj-aoc.rkt"
         awesome-list
         threading
         racket/struct)

(struct coord (x y z) #:transparent)

(define (coord-broadcast f c1 c2)
  (match-define (coord x1 y1 z1) c1)
  (match-define (coord x2 y2 z2) c2)
  (coord (f x1 x2) (f y1 y2) (f z1 z2)))

(define (coord-reduce f c1 c2)
  (foldl (λ (i1 i2 acc) (+ acc (f i1 i2)))
         0
         (struct->list c1)
         (struct->list c2)))

(define coord-delta (curry coord-broadcast -))
(define coord-sum (curry coord-broadcast +))
(define coord-manhattan (curry coord-reduce (coord 0 0 0)))

(define (create-scan-data d)
  (for/list ([l (in-list d)])
    (for/list ([pt (in-list (~> (string-split l "\n")
                              rest))])
      (~>> pt
           (regexp-match #px"(-?\\d+),(-?\\d+),(-?\\d+)")
           rest
           (map string->number)
           (apply coord)))))

(define scanner-data (create-scan-data (~>> (open-day 19 2021)
                                            port->string
                                            (string-split _ "\n\n"))))

(define test-scanner-data (create-scan-data (~>> (open-input-file "test-scanners")
                                                 port->string
                                                 (string-split _ "\n\n"))))

(define (generate-rotations scanner)
  (transpose
   (for*/list ([pt (in-list scanner)])
     (match-define (coord x y z) pt)
     (define orientations (list (list x y z)
                                (list x z (- y))
                                (list x (- y) (- z))
                                (list x (- z) y)))
     (append*
      (for/list ([o (in-list orientations)])
        (match-define (list x* y* z*) o)
        (list (list x y z)
              (list (- x) z y)
              (list z (- y) x)
              (list y x (- z))
              (list (- y) (- z) x)))))))

(define (find-overlaps scan1 scan2)
  (for/list ([rotation (in-permutations scan2)])
    (map coord-sum scan1 rotation)))

(first test-scanner-data)
(find-overlaps (first test-scanner-data) (second test-scanner-data))
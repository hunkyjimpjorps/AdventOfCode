#lang racket
(require advent-of-code
         threading)

(struct coord (x y))

(define input (~> (fetch-aoc-input (find-session) 2023 18 #:cache #true)))

(define (go-to-next-coord c dir dist)
  (match-define (coord x y) c)
  (match dir
    [(or "R" "0") (coord (+ x dist) y)]
    [(or "D" "1") (coord x (- y dist))]
    [(or "L" "2") (coord (- x dist) y)]
    [(or "U" "3") (coord x (+ y dist))]))

(define/match (triangle-area _coord1 _coord2)
  [((coord x1 y1) (coord x2 y2)) (/ (- (* x1 y2) (* x2 y1)) 2)])

(define (find-area-using parser)
  (for/fold ([area 0]
             [perimeter 0]
             [current-coord (coord 0 0)]
             #:result (+ 1 (abs area) (/ perimeter 2)))
            ([dig (in-list (string-split input "\n"))])
    (define-values (dir dist) (parser dig))
    (define next-coord (go-to-next-coord current-coord dir dist))
    (values (+ area (triangle-area current-coord next-coord)) 
            (+ perimeter dist) next-coord)))

;; part 1
(define (parse-front dig)
  (match-define (regexp #rx"(.) (.*) \\((.*)\\)" 
                        (list _ dir (app string->number dist) _hex)) 
    dig)
  (values dir dist))

(find-area-using parse-front)

;; part 2

(define (parse-hex dig)
  (match-define (regexp #rx".*\\(#(.....)(.)\\)" 
                        (list _ (app (curryr string->number 16) dist) dir))
    dig)
  (values dir dist))

(find-area-using parse-hex)

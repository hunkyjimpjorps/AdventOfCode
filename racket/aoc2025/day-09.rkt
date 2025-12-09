#lang racket

(require advent-of-code
         threading
         algorithms)

(struct Posn (x y))

(define red-tiles
  (for/list ([line (in-lines (open-aoc-input (find-session) 2025 9 #:cache #true))])
    (~> line (string-split _ ",") (map string->number _) (apply Posn _))))

(define/match (area _pair)
  [((list (Posn x1 y1) (Posn x2 y2))) (* (add1 (abs (- x1 x2))) (add1 (abs (- y1 y2))))])

(define rectangles (~> red-tiles (combinations 2) (sort > #:key area)))

;; part 1
(~> rectangles first area)

;; part 2
(define poly-sides (sliding (cons (last red-tiles) red-tiles) 2))

(define (rectangle-hits-polygon? rect)
  (match-let* ([(list (Posn x1 y1) (Posn x2 y2)) rect]
               [(list rect-min-x rect-max-x) (sort (list x1 x2) <)]
               [(list rect-min-y rect-max-y) (sort (list y1 y2) <)])
    (for/or ([side (in-list poly-sides)])
      (match-let* ([(list (Posn px1 py1) (Posn px2 py2)) side]
                   [side-max-x (max px1 px2)] [side-min-x (min px1 px2)]
                   [side-max-y (max py1 py2)] [side-min-y (min py1 py2)])
        (not (or (<= side-max-x rect-min-x)
                 (>= side-min-x rect-max-x)
                 (<= side-max-y rect-min-y)
                 (>= side-min-y rect-max-y)))))))

(for/first ([rect (in-list rectangles)]
            #:unless (rectangle-hits-polygon? rect))
  (area rect))

#lang racket
(require advent-of-code
         threading)

(struct cmd (dir amt))
(struct posn (x y) #:transparent)

(define moves
  (~> (fetch-aoc-input (find-session) 2022 9)
      (string-split "\n")
      (map (λ~> (string-split _)
                (match _
                  [(list dir amt) (cmd (string->symbol dir) (string->number amt))]))
           _)))

(define (move-head p dir)
  (match* (p dir)
    [((posn x y) 'U) (posn x (add1 y))]
    [((posn x y) 'D) (posn x (sub1 y))]
    [((posn x y) 'R) (posn (add1 x) y)]
    [((posn x y) 'L) (posn (sub1 x) y)]))

(define (avg n m)
  (/ (+ n m) 2))

(define (manhattan-distance p1 p2)
  (match-define (posn x1 y1) p1)
  (match-define (posn x2 y2) p2)
  (+ (abs (- x2 x1)) (abs (- y2 y1))))

(define (follow-head head tail)
  (match-define (posn hx hy) head)
  (match-define (posn tx ty) tail)

  (case (manhattan-distance head tail)
    [(0 1) tail]
    [(2 4)
     (cond
       [(and (= 1 (abs (- hx tx)) (abs (- hy ty)))) tail]
       [else (posn (avg hx tx) (avg hy ty))])]
    [(3)
     (cond
       [(= 2 (abs (- hx tx))) (posn (avg hx tx) hy)]
       [(= 2 (abs (- hy ty))) (posn hx (avg hy ty))])]))

;; part 1
(for*/fold ([head (posn 0 0)] [tail (posn 0 0)] [tail-posns (set)] #:result (set-count tail-posns))
           ([move (in-list moves)] #:do [(match-define (cmd dir amt) move)] [_ (in-range amt)])
  (define new-head (move-head head dir))
  (define new-tail (follow-head new-head tail))
  (values new-head new-tail (set-add tail-posns new-tail)))

;; part 2
(for*/fold ([knots (make-list 10 (posn 0 0))] [tail-posns (set)] #:result (set-count tail-posns))
           ([move (in-list moves)] #:do [(match-define (cmd dir amt) move)] [_ (in-range amt)])
  (define updated-knots
    (for/fold ([knots-list (list (move-head (first knots) dir))])
              ([following-knot (in-list (rest knots))])
      (cons (follow-head (car knots-list) following-knot) knots-list)))
  (values (reverse updated-knots) (set-add tail-posns (first updated-knots))))

;; refactor: part 1 and 2 combined
(define (follow-tail move-list rope-length)
  (for*/fold ([knots (make-list rope-length (posn 0 0))]
              [tail-posns (set)]
              #:result (set-count tail-posns))
             ([move (in-list move-list)] #:do [(match-define (cmd dir amt) move)] [_ (in-range amt)])
    (define updated-knots
      (for/fold ([knots-list (list (move-head (first knots) dir))])
                ([following-knot (in-list (rest knots))])
        (cons (follow-head (car knots-list) following-knot) knots-list)))
    (values (reverse updated-knots) (set-add tail-posns (first updated-knots)))))

(time (follow-tail moves 2))
(time (follow-tail moves 10))

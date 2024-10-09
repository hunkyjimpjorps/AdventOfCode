#lang racket

(require advent-of-code
         threading
         fancy-app
         data/collection)

(define (relative-rock-coordinates rock)
  (for*/hash ([(row y) (in-indexed (reverse rock))] [(_col x) (in-indexed row)])
    (values (cons x y) #true)))

(define rock-shapes
  (~> (open-input-file "./2022/day-17/rock-shapes")
      port->string
      (string-split "\n\n")
      (map (λ~> (string-split _ "\n") (map string->list _) relative-rock-coordinates) _)))

(define gusts
  (~> (fetch-aoc-input (find-session) 2022 17 #:cache #true)
      string-trim
      string->list
      (map (match-lambda
             [#\> 1]
             [#\< -1])
           _)))

(define (place-new-rock rock elevation)
  (for/hash ([(posn _) (in-hash rock)])
    (match-define (cons x y) posn)
    (values (cons (+ x 3) (+ y elevation 4)) #true)))

(define (gust-move rock wind cave)
  (define moved-rock
    (for/hash ([(posn _) (in-hash rock)])
      (match-define (cons x y) posn)
      (define posn* (cons (+ x wind) y))
      (if (hash-has-key? cave posn) (values 'collision #t) (values posn* #t))))
  (if (hash-has-key? moved-rock 'collision) rock moved-rock))

(for/fold ([cave (hash)]
           [falling-rock #f]
           [top-of-rocks 0]
           [rock-cycle (cycle rock-shapes)]
           [rock-number 0]
           #:result top-of-rocks)
          (#:break (> rock-number 2022) [gust (in-cycle gusts)])
  (cond
    [(not falling-rock)
     (values cave
             (~> (first rock-cycle) (place-new-rock top-of-rocks) (gust-move gust cave))
             top-of-rocks
             (rest rock-cycle)
             (add1 rock-number))]))

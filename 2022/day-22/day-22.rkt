#lang racket

(require advent-of-code
         threading)

(struct posn (x y) #:transparent)

(match-define (list raw-map raw-instructions)
  (string-split (fetch-aoc-input (find-session) 2022 22 #:cache #true) "\n\n"))

(define board-map
  (for*/hash ([(row y) (in-indexed (string-split raw-map "\n"))]
              [(col x) (in-indexed row)]
              #:unless (equal? col #\space))
    (define tile
      (match col
        [#\. 'open]
        [#\# 'wall]))
    (values (posn x y) tile)))

(define instructions
  (~>> raw-instructions
       (regexp-match* #px"(\\d+)|R|L")
       (map (match-lambda
              [(? string->number n) (string->number n)]
              ["R" 'clockwise]
              ["L" 'counterclockwise]))))

(define start-tile
  (~>> board-map
       hash-keys
       (filter (match-lambda
                 [(posn _ 0) #true]
                 [_ #false]))
       (argmin posn-x)))
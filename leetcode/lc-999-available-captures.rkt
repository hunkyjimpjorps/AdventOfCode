#lang racket
(define/contract (num-rook-captures board)
  (-> (listof (listof string?)) exact-integer?)

  (define (get-rook-space [board-state board])
    (for/or ([board-rank (in-list board-state)]
             [rank (in-range 0 (length board-state))]
             #:when (index-of board-rank "R"))
      (list rank (index-of board-rank "R"))))

  (define (check-for-capturable-pawns spaces)
    (match spaces
      [(list _ ... "p" "." ... "R" "." ... "p" _ ...) 2]
      [(list _ ... "R" "." ... "p" _ ...) 1]
      [(list _ ... "p" "." ... "R" _ ...) 1]
      [_ 0]))

  (define (check-rank rank [board-state board])
    (let ([spaces (list-ref board-state rank)])
      (check-for-capturable-pawns spaces)))

  (define (check-file file [board-state board])
    (let ([spaces (map (curryr list-ref file) board)])
      (check-for-capturable-pawns spaces)))

  (match (get-rook-space board)
    [(list rank file) (+ (check-rank rank)
                         (check-file file))]))
#lang racket

(define/contract (judge-circle moves)
  (-> string? boolean?)
  (equal? '(0 0)
          (for/fold ([y-pos 0]
                     [x-pos 0]
                     #:result (list y-pos x-pos))
                    ([move (map string (string->list moves))])
            (values (case move
                      [("U") (add1 y-pos)]
                      [("D") (sub1 y-pos)]
                      [else y-pos])
                    (case move
                      [("L") (add1 x-pos)]
                      [("R") (sub1 x-pos)]
                      [else x-pos])))))
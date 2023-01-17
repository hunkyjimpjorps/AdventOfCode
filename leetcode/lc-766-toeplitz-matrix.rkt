#lang racket

(define/contract (is-toeplitz-matrix matrix)
  (-> (listof (listof exact-integer?)) boolean?)
  (cond [(empty? (cdr matrix)) #true]
        [(equal? (drop-right (car matrix) 1)
                 (drop (cadr matrix) 1))
         (is-toeplitz-matrix (cdr matrix))]
        [else #false]))
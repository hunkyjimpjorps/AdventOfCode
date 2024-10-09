#lang racket
(define/contract (contains-duplicate nums)
  (-> (listof exact-integer?) boolean?)
  (define nums-hash (make-hash))
  (define (check-next-number nums)
    (cond [(empty? nums) #false]
          [(hash-ref nums-hash (car nums) #false) #true]
          [else (hash-set! nums-hash (car nums) #true)
                (check-next-number (cdr nums))]))
  (check-next-number nums))

(contains-duplicate '(1 2 3))
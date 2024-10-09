#lang racket
(define/contract (is-monotonic test-list)
  (-> (listof exact-integer?) boolean?)
  (cond [(empty? (cdr test-list)) #true]
        [((car test-list) . > . (cadr test-list))
         (is-monotonic-direction test-list >=)]
        [((car test-list) . < . (cadr test-list))
         (is-monotonic-direction test-list <=)]
        [else (is-monotonic (cdr test-list))]))

(define/contract (is-monotonic-direction test-list dir)
  (-> (listof exact-integer?) procedure? boolean?)
  (cond [(empty? (cdr test-list)) #true]
        [((car test-list) . dir . (cadr test-list))
         (is-monotonic-direction (cdr test-list) dir)]
        [else #false]))
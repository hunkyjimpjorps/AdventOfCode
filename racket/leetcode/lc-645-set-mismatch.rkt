#lang racket

(define/contract (find-error-nums nums)
  (-> (listof exact-integer?) (listof exact-integer?))
  (define nums-set (list->set nums))
  (define range-set (apply set (range 1 (+ 2 (set-count nums-set)))))
  (define missing-num (first (set->list (set-subtract range-set nums-set))))
  (define necessary-num
    (if (set-member? nums-set (- missing-num 1))
        (+ missing-num 1)
        (- missing-num 1)))
  (list missing-num necessary-num))

(find-error-nums '(1 2 2 4))

(define fact-stream
  (letrec ([f (lambda (x y)
                (cond
                  [(zero? (modulo (- y 1) 3)) (cons (* 3 x) (lambda() (f (* x
                                                                            y) (+ y 1))))]
                  [else (cons x (lambda() (f (* x y) (+ y 1))))])
                [else (cons x (lambda() (f (* x y) (+ y 1))))]
                (lambda () (f 1 2))
                )])))
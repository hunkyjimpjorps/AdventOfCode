#lang racket
(define/contract (add-to-array-form num k)
  (-> (listof exact-integer?) exact-integer? (listof exact-integer?))
  (define rev-num (reverse num))
  (define raw-array-form
    (cond [(= k 0) num]
          [else
           (for/fold ([sum-list '()]
                      [addend k]
                      [carry 0]
                      #:result sum-list)
                     ([place (append rev-num
                                     (make-list (add1 (order-of-magnitude k)) 0))])
             (let* ([place-sum (+ place carry (modulo addend 10))]
                    [to-carry (quotient place-sum 10)]
                    [new-place (modulo place-sum 10)])
               (values (cons new-place sum-list)
                       (quotient addend 10)
                       to-carry)))]))
  (match-define-values
    (result _) (drop-common-prefix raw-array-form
                                   (make-list (length raw-array-form) 0)))
  (cond [(empty? result) '(0)]
        [else result]))
#lang racket

(define/contract (convert-to-base7 num)
  (-> exact-integer? string?)
  (define (max-base-power n base [pow 1])
    (cond [(n . = . (expt base pow)) pow]
          [(n . < . (expt base pow)) (sub1 pow)]
          [else (max-base-power n base (add1 pow))]))
  (define (add-next-digit n pow acc)
    (cond [(= pow 0) (string-append acc (number->string n))]
          [else (add-next-digit (remainder n (expt 7 pow))
                                (sub1 pow)
                                (string-append acc
                                               (number->string (quotient n (expt 7 pow)))))]))
  (string-append (if (negative? num) "-"  "")
                 (add-next-digit (abs num) (max-base-power (abs num) 7) "")))
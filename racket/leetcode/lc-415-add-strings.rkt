#lang racket

(define/contract (add-strings num1 num2)
  (-> string? string? string?)
  (define (char->integer c)
    ((compose string->number string) c))
  (define pad-length
    (add1 (apply max (map string-length (list num1 num2)))))
  (define (pad-with-zeroes n)
    (~a n
        #:align 'right
        #:min-width pad-length 
        #:pad-string "0"))
  (define (string-reverse s)
    ((compose list->string reverse string->list) s))
  (define raw-sum
    (for/fold ([sum-string ""]
               [carry 0]
               #:result sum-string)
              ([n1 (string-reverse (pad-with-zeroes num1))]
               [n2 (string-reverse (pad-with-zeroes num2))])
      (let* ([digit-sum (+ carry (char->integer n1) (char->integer n2))]
             [sum-place (number->string (modulo digit-sum 10))]
             [sum-carry (quotient digit-sum 10)])
        (values (string-append sum-place sum-string)
                sum-carry))))
  (cond [(equal? raw-sum "00") "0"]
        [else (string-trim raw-sum "0" #:repeat? #t #:right? #f)]))
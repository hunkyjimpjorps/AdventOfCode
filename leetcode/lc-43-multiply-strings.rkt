#lang racket

(define/contract (char-digit->integer c)
  (-> char? integer?)
  (- (char->integer c) 48))

(define/contract (integer->string-digit n)
  (-> integer? string?)
  (string (integer->char (+ n 48))))

(define/contract (number->string1 n [acc ""])
  (->* (integer?) (string?) string?)
  (cond [(and (= n 0) (equal? acc "")) "0"]
        [(= n 0) acc]
        [else (number->string1
               (quotient n 10)
               (string-append (integer->string-digit (remainder n 10)) acc))]))

(define/contract (multiply num1 num2)
  (-> string? string? string?)
  (define multiplication-steps
    (for/list ([n1 (in-string num1)]
               [place1 (in-range (sub1 (string-length num1)) -1 -1)])
      (for/list ([n2 (in-string num2)]
                 [place2 (in-range (sub1 (string-length num2)) -1 -1)])
        (apply * (append (map char-digit->integer (list n1 n2))
                         (list (expt 10 place1) (expt 10 place2)))))))
  (number->string1 (apply + (flatten multiplication-steps))))
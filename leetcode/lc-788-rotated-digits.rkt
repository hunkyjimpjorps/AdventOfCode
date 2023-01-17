#lang racket

(define/contract (rotated-digits max-n)
  (-> exact-integer? exact-integer?)
  (for/fold ([good-number-count 0])
            ([n (in-range 1 (add1 max-n))])
    (if (is-good? n)
        (add1 good-number-count)
        good-number-count)))

(define/contract (is-good? test-number)
  (-> exact-integer? boolean?)
  (define test-string (number->string test-number))
  (match test-string
    [(regexp #rx"^[018]*$") #false]
    [(regexp #rx"^[0125689]*$") #true]
    [_ #false]))
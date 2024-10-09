#lang racket
(define/contract (is-palindrome x)
  (-> exact-integer? boolean?)
  ; get the easy cases out of the way first
  ; negative numbers are not palindromes, single-digit numbers are
  (cond [(x . < . 0) #false]
        [(x . < . 10) #true]
        [else
         ; order-of-magnitude returns the scientific notation exponent
         ; so add 1 to get the number of digits
         (define digits
           (add1 (order-of-magnitude x)))
         ; figure out how many digits we need to trim to find the mirrored halves
         ; if there are an even number of digits 2n, we will remove n of them from the right
         ; if there are an odd number of digits 2n+1, we will remove n+1 of them from the right
         (define half-digits
           (cond [(even? digits) (/ digits 2)]
                 [else (/ (add1 digits) 2)]))
         ; divide x by a power of 10 to get the digits to match
         (define front-half
           (quotient x (expt 10 half-digits)))
         ; reverse the back half with repeated divisions by 10
         (define back-half-reversed
           (for/fold ([reversed 0]
                      [remaining (remainder x (expt 10 half-digits))]
                      ; build up the sum of the digits in reversed and return it at the end
                      #:result reversed)
                     ; if we have an odd number of digits, we don't need to match the middle one
                     ([n (in-range (if (even? digits)
                                       half-digits
                                       (sub1 half-digits)))])
             ; shift all the accumulated digits in the mirror to the left one place
             ; and add the next one to the right,
             ; then chop the right-most digit off the original
             (values (+ (* 10 reversed) (remainder remaining 10))
                     (quotient remaining 10))))
         ; finally, check to see if the mirrored right is equal to the original left
         (= front-half back-half-reversed)]))

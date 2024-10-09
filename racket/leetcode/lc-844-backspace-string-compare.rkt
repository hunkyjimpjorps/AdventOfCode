#lang racket

(define/contract (process-backspace-string strng)
  (-> string? string?)
  (apply ~a (for/fold ([str-out '()]
                       #:result (reverse str-out))
                      ([character (in-string strng)])
              (case character
                [(#\#) (if (empty? str-out)
                           str-out
                           (cdr str-out))]
                [else (cons character str-out)]))))

(define/contract (backspace-compare s t)
  (-> string? string? boolean?)
  (equal? (process-backspace-string s)
          (process-backspace-string t)))
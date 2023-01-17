#lang racket

(define/contract (is-palindrome s)
  (-> string? boolean?)
  (define clean-string
    (string-downcase (string-replace s #rx"[^A-Za-z0-9]" "")))
  (string-prefix? (apply string-append (map string (reverse (string->list clean-string))))
                  (substring clean-string
                             0
                             (ceiling (/ (string-length clean-string) 2)))))

(is-palindrome "A man, a plan, a canal: Panama")
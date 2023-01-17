#lang racket
(define/contract (replace-digits s)
  (-> string? string?)
  (define/contract (shift-letter c x)
    (-> char? char? char?)
    (integer->char (+ (string->number (string x)) (char->integer c))))
  (define letters (string->list (string-replace s #rx"[0-9]" "")))
  (define digits (string->list (string-replace s #rx"[a-z]" "")))
  (foldl (λ (c x acc)
           (if (equal? x #\X)
               (string-append acc (string c))
               (string-append acc (string c) (string (shift-letter c x)))))
         ""
         letters
         (if (= (length digits) (length letters))
             digits
             (append digits '(#\X)))
         ))
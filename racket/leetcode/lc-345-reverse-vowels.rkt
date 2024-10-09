#lang racket

(define/contract (reverse-vowels s)
  (-> string? string?)
  (define vowels-only
    (string-replace s #rx"[^aeiouAEIOU]" ""))
  (define consonants-with-placeholders
    (string-replace s #rx"[aeiouAEIOU]" "~a"))
  (apply format consonants-with-placeholders (reverse (string->list vowels-only))))
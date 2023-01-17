#lang racket

(define/contract (length-of-last-word s)
  (-> string? exact-integer?)
  (if (empty? (string-split s))
      0
      (string-length (last (string-split s)))))
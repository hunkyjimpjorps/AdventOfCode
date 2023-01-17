#lang racket

(define/contract (num-jewels-in-stones jewels stones)
  (-> string? string? exact-integer?)
  (for/sum ([jewel (in-string jewels)])
    (count (curry char=? jewel) (string->list stones))))
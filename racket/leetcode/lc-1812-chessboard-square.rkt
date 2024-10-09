#lang racket
(define/contract (square-is-white coordinates)
  (-> string? boolean?)
  (define file (first (string->list coordinates)))
  (define rank (second (string->list coordinates)))
  (or (and (odd? (char->integer file)) (even? (char->integer rank)))
      (and (even? (char->integer file)) (odd? (char->integer rank)))))
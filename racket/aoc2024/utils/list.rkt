#lang racket
(provide transpose)

(define (transpose xss)
  (apply map list xss))

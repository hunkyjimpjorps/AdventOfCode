#lang racket
(require "../../jj-aoc.rkt"
         threading
         racket/struct)

(struct present (l w h) #:transparent)

(define presents
  (for/list ([size-string (in-lines (open-day 2 2015))])
    (~> size-string
        (string-split "x")
        (map string->number _)
        (apply present _))))

;; part 1
(define (paper-area p)
  (define main-area
    (~> p
        struct->list
        (combinations 2)
        (map (λ~> (apply * 2 _)) _)
        (apply + _)))
  (define slack-area
    (~> p
        struct->list
        (sort <)
        (take 2)
        (apply * _)))
  (+ main-area slack-area))

(for/sum ([p (in-list presents)]) (paper-area p))

;; part 2
(define (ribbon-length p)
  (define ribbon-around-box
    (~> p
        struct->list
        (sort <)
        (take 2)
        (map (λ~> (* 2)) _)
        (apply + _)))
  (define ribbon-for-bow
    (~> p
        struct->list
        (apply * _)))
  (+ ribbon-around-box ribbon-for-bow))

(for/sum ([p (in-list presents)]) (ribbon-length p))
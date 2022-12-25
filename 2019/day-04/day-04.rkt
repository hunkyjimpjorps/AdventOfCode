#lang racket

(define (number->digits n [acc '()])
  (cond
    [(< n 10) (cons n acc)]
    [else (number->digits (quotient n 10) (cons (remainder n 10) acc))]))

(define (always-increasing? xs)
  (match xs
    [(list _) #t]
    [(list* a b _) #:when (<= a b) (always-increasing? (cdr xs))]
    [_ #f]))

(define (adjacent-pair? xs)
  (match xs
    [(list _) #f]
    [(list* a a _) a]
    [_ (adjacent-pair? (cdr xs))]))

;; part 1
(for/sum ([password (inclusive-range 125730 579381)]
          #:do [(define digits (number->digits password))]
          #:when ((conjoin always-increasing? adjacent-pair?) digits))
  1)

;; part 2
(define (not-in-adjacent-triplet? xs)
  (match xs
    [(list a a c _ _ _) #:when (not (= a c)) #t]
    [(list b a a c _ _) #:when (not (or (= a b) (= a c))) #t]
    [(list _ b a a c _) #:when (not (or (= a b) (= a c))) #t]
    [(list _ _ b a a c) #:when (not (or (= a b) (= a c))) #t]
    [(list _ _ _ b a a) #:when (not (= a b)) #t]
    [_ #f]))

(for/sum ([password (inclusive-range 125730 579381)]
          #:do [(define digits (number->digits password))]
          #:when ((conjoin always-increasing? adjacent-pair? not-in-adjacent-triplet?) digits))
  1)
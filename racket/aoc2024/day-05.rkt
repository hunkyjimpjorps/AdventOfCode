#lang racket

(require advent-of-code)

(define raw-data (fetch-aoc-input (find-session) 2024 5 #:cache #t))

(match-define (list raw-pairs raw-updates) (string-split raw-data "\n\n"))

(define PAIRS
  (for/set ([pair (in-list (string-split raw-pairs "\n"))])
    (for/list ([n (in-list (string-split pair "|"))])
      (string->number n))))

(define updates
  (for/list ([update (in-list (string-split raw-updates "\n"))])
    (for/list ([n (in-list (string-split update ","))])
      (string->number n))))

(define (middle xs)
  (list-ref xs (/ (sub1 (length xs)) 2)))

(define (page-order a b)
  (set-member? PAIRS (list a b)))

;; part 1
(for/sum ([update (in-list updates)] ;
          #:do [(define sorted (sort update page-order))]
          #:when (equal? update sorted))
         (middle update))

;; part 2
(for/sum ([update (in-list updates)] ;
          #:do [(define sorted (sort update page-order))]
          #:unless (equal? update sorted))
         (middle sorted))

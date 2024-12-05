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
  (define (do-middle [one-step xs] [two-step xs])
    (match two-step
      [(or (list) (list _)) (first one-step)]
      [(list* _ _ tail) (do-middle (rest one-step) tail)]))
  (do-middle))

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

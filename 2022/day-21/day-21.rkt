#lang racket

(require advent-of-code
         (only-in relation ->number ->symbol))

(struct monkey (name op) #:transparent)
(struct op (f first second) #:transparent)

(define (parse-monkey str)
  (match (string-split str " ")
    [(list (app (curryr string-trim ":") name) name1 (app ->symbol f) name2)
     (monkey name (op f name1 name2))]
    [(list (app (curryr string-trim ":") name) (app ->number int))
     (monkey name (op 'constant int #f))]))

(define raw-monkeys (port->lines (open-aoc-input (find-session) 2022 21 #:cache #true)))

(define monkey-table
  (for/hash ([m raw-monkeys] #:do [(match-define (monkey name op) (parse-monkey m))])
    (values name op)))

;; part 1
(define (evaluate-monkey m-name [guess #f])
  (match-define (op f name1 name2)
    (if (and guess (equal? m-name "humn")) (op 'constant guess #f) (hash-ref monkey-table m-name)))
  (match f
    ['constant name1]
    ['+ (+ (evaluate-monkey name1 guess) (evaluate-monkey name2 guess))]
    ['- (- (evaluate-monkey name1 guess) (evaluate-monkey name2 guess))]
    ['* (* (evaluate-monkey name1 guess) (evaluate-monkey name2 guess))]
    ['/ (/ (evaluate-monkey name1 guess) (evaluate-monkey name2 guess))]))

(evaluate-monkey "root")

;; part 2
(match-define (op _ branch-1 branch-2) (hash-ref monkey-table "root"))

;; the branch that doesn't depend on humn
(define known-side (evaluate-monkey branch-2))

(for/fold ([lower-bound 0] [upper-bound 1e16] #:result (inexact->exact lower-bound))
          ([_ (in-naturals)])
  #:break (= lower-bound upper-bound)
  (define midpoint (quotient (+ lower-bound upper-bound) 2))
  (define candidate (evaluate-monkey branch-1 midpoint))
  (println (~a midpoint " -> " candidate " -> " (- candidate known-side)))
  (cond
    [(= candidate known-side) (values midpoint midpoint)]
    [(> candidate known-side) (values midpoint upper-bound)]
    [(< candidate known-side) (values lower-bound midpoint)]))

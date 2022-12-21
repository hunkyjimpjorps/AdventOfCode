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

(define (parse f name1 name2)
  (match f
    ['constant name1]
    ['+ (+ (evaluate-monkey name1) (evaluate-monkey name2))]
    ['- (- (evaluate-monkey name1) (evaluate-monkey name2))]
    ['* (* (evaluate-monkey name1) (evaluate-monkey name2))]
    ['/ (/ (evaluate-monkey name1) (evaluate-monkey name2))]))

;; part 1
(define (evaluate-monkey m-name)
  (match-define (op f name1 name2) (hash-ref monkey-table m-name))
  (parse f name1 name2))

(evaluate-monkey "root")

;; part 2
(match-define (op _ branch-1 branch-2) (hash-ref monkey-table "root"))

(define (evaluate-monkey* m-name guess)
  (match-define (op f name1 name2)
    (if (equal? m-name "humn") (op 'constant guess #f) (hash-ref monkey-table m-name)))
  (match f
    ['constant name1]
    ['+ (+ (evaluate-monkey* name1 guess) (evaluate-monkey* name2 guess))]
    ['- (- (evaluate-monkey* name1 guess) (evaluate-monkey* name2 guess))]
    ['* (* (evaluate-monkey* name1 guess) (evaluate-monkey* name2 guess))]
    ['/ (/ (evaluate-monkey* name1 guess) (evaluate-monkey* name2 guess))]))

;; the branch that doesn't depend on humn
(define result-2 (evaluate-monkey branch-2))

;; I plugged in numbers for guess to find a suitable starting range and settled on the first one
;; that I found that got me within a million
(for/first ([guess (in-naturals 3059361690000)]
            #:do [(define result-1 (evaluate-monkey* branch-1 guess))]
            #:when (= result-1 result-2))
  guess)

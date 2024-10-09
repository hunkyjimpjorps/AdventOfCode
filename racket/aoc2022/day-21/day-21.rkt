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
;; since humn only ever appears once, and it's never the divisor in a division operation,
;; the difference of the branches is linearly proportional to humn
;; therefore, if we find two points we can calculate the root directly
(match-define (op _ branch-1 branch-2) (hash-ref monkey-table "root"))
(define known-side (evaluate-monkey branch-2))
(define humn-zero (- known-side (evaluate-monkey branch-1 0)))
(define humn-one (- known-side (evaluate-monkey branch-1 1)))
(- (/ humn-zero (- humn-one humn-zero)))

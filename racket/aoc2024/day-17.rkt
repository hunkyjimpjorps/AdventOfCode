#lang racket

(require advent-of-code
         threading
         struct-update)

(struct Computer (a b c pointer commands output) #:transparent)
(define-struct-updaters Computer)

(define (vector-ref* vec i [default 'out-of-range])
  (with-handlers ([exn:fail:contract? (λ (_) default)])
    (vector-ref vec i)))

(define (make-default-register input)
  (match-define (list a b c)
    (~> input
        (regexp-match* #px"Register .: (\\d+)\n" _ #:match-select second)
        (map string->number _)))
  (define commands
    (~> input
        (regexp-match #px"Program: (.+)\n" _)
        second
        (string-split ",")
        (list->vector)
        (vector-map string->number _)))
  (Computer a b c 0 commands '()))

(define starting-computer
  (~> (fetch-aoc-input (find-session) 2024 17 #:cache #true) make-default-register))

(define add2 (curry + 2))

(define (as-combo operand r)
  (match operand
    [(or 0 1 2 3) operand]
    [4 (Computer-a r)]
    [5 (Computer-b r)]
    [6 (Computer-c r)]))

(define (do-op instruction operand comp)
  (match instruction
    [0
     (~> comp
         (Computer-a-update (λ (a) (quotient a (expt 2 (as-combo operand comp)))))
         (Computer-pointer-update add2))]
    [1
     (~> comp
         (Computer-b-update (curry bitwise-xor operand)) ;
         (Computer-pointer-update add2))]
    [2
     (~> comp
         (Computer-b-set (modulo (as-combo operand comp) 8)) ;
         (Computer-pointer-update add2))]
    [3
     (if (zero? (Computer-a comp))
         (Computer-pointer-update comp add2)
         (Computer-pointer-set comp operand))]
    [4
     (~> comp
         (Computer-b-update (curry bitwise-xor (Computer-c comp))) ;
         (Computer-pointer-update add2))]
    [5
     (~> comp
         (Computer-output-update (λ (out) (cons (modulo (as-combo operand comp) 8) out)))
         (Computer-pointer-update add2))]
    [6
     (~> comp
         (Computer-b-set (quotient (Computer-a comp) (expt 2 (as-combo operand comp))))
         (Computer-pointer-update add2))]
    [7
     (~> comp
         (Computer-c-set (quotient (Computer-a comp) (expt 2 (as-combo operand comp))))
         (Computer-pointer-update add2))]))

(define (run-program comp)
  (match-define (Computer _ _ _ pointer commands output) comp)
  (define instruction (vector-ref* commands pointer))
  (define operand (vector-ref* commands (add1 pointer)))
  (if (or (equal? instruction 'out-of-range) (equal? operand 'out-of-range))
      (reverse output)
      (~>> comp (do-op instruction operand) run-program)))

; part 1
(~> (run-program starting-computer) (apply ~a _ #:separator ","))

; part 2
(define (is-prefix-of? as bs)
  (match* (as bs)
    [('() _) #true]
    [((list* a a-rest) (list* a b-rest)) (is-prefix-of? a-rest b-rest)]
    [(_ _) #false]))

(define (search-for-a acc goal comp)
  (match acc
    ['() #f]
    [(list* next rest)
     (define trial-quine (~> comp (Computer-a-set next) run-program reverse))
     (cond
       [(equal? trial-quine goal) next]
       [(is-prefix-of? trial-quine goal)
        (~> (inclusive-range 0 7)
            (map (λ (n) (+ n (* 8 next))) _)
            (append rest)
            (search-for-a _ goal comp))]
       [else (search-for-a rest goal comp)])]))

(~> starting-computer
    Computer-commands
    vector->list
    reverse
    (search-for-a (inclusive-range 0 7) _ starting-computer))

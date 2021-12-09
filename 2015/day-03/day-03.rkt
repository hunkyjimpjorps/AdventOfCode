#lang racket
(require "../../jj-aoc.rkt"
         threading
         (only-in algorithms chunks-of)
         (only-in awesome-list transpose)
         racket/hash)

(define directions
  (for/list ([l (in-input-port-chars (open-day 3 2015))])
    (string->symbol (string l))))

(define (trace-santa dirs)
  (define visits (make-hash))
  (for/fold ([x 0]
             [y 0]
             #:result visits)
            ([dir (in-list dirs)])
    (hash-set! visits `(,x ,y) #true)
    (match dir
      ['^ (values x (add1 y))]
      ['v (values x (sub1 y))]
      ['< (values (add1 x) y)]
      ['> (values (sub1 x) y)])))

;; part 1
(~> directions trace-santa hash-values length)

;; part 2
(~> directions
    (chunks-of 2)
    transpose
    (map trace-santa _)
    (match-define (list real robo) _))

(hash-union! real robo #:combine (λ _ #true))
(~> real hash-values length)
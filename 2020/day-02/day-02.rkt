#lang racket
(require "../../jj-aoc.rkt"
         threading)

(struct policy (least most char pwd) #:transparent)

(define (make-policy least-str most-str char-str pwd)
  (policy (string->number least-str)
          (string->number most-str)
          (string-ref char-str 0)
          pwd))

(define policies
  (for/list ([l (in-lines (open-day 02 2020))])
    (~>> l
         (regexp-match #px"(\\d+)-(\\d+) (\\w): (.*)")
         rest
         (apply make-policy))))

;; part 1
(define (valid-policy? p)
  (~>> p
       policy-pwd
       string->list
       (count (curry char=? (policy-char p)))
       ((λ (n) (and (>= n (policy-least p))
                    (<= n (policy-most p)))))))

(for/sum ([p (in-list policies)]
          #:when (valid-policy? p))
  1)

;; part 2
(define (valid-revised-policy? p)
  (~>> p
       policy-pwd
       string->list
       ((λ (lst) (list (list-ref lst (sub1 (policy-most p)))
                       (list-ref lst (sub1 (policy-least p))))))
       (count (curry char=? (policy-char p)))
       (= 1)))

(for/sum ([p (in-list policies)]
          #:when (valid-revised-policy? p))
  1)
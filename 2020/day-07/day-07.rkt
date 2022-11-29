#lang racket
(require "../../jj-aoc.rkt"
         threading
         rebellion/collection/entry
         rebellion/collection/multidict)

(define raw-rules (~> (open-day 7 2020) (port->string) (string-split "\n")))

(define (split-rule r)
  (match-define (list head tail) (string-split (string-trim r #px" bags?.") " bags contain "))
  (~>> tail
       (regexp-split #px"( bags?,\\s)" _)
       (map (λ~> (regexp-match* #px"(\\d+) (\\w+ \\w+)" _ #:match-select rest)))
       append*
       (map (λ~> (match _
                   [(list n c) (list (string->symbol c) (string->number n))]
                   ['() '()])))
       (cons (string->symbol head) _)))

(define rules-multidict
  (for*/multidict ([ln (in-list raw-rules)] #:do [(match-define (list* from tos) (split-rule ln))]
                                            [to (in-list tos)])
    (entry from to)))

;; part 1

(define (bags-that-eventually-contain target)
  (for/fold ([holders (set)]) ([rule (in-multidict-entries rules-multidict)])
    (match rule
      [(entry outside (list (== target) _))
       (set-union (set-add holders outside) (bags-that-eventually-contain outside))]
      [_ holders])))

(time (set-count (bags-that-eventually-contain '|shiny gold|)))

;; part 2

(define (bags-that-are-contained-by target)
  (for/sum ([holding (in-multidict-entries rules-multidict)])
           (match holding
             [(entry (== target) (list held n)) (+ n (* n (bags-that-are-contained-by held)))]
             [_ 0])))

(time (bags-that-are-contained-by '|shiny gold|))

#lang racket
(require "../../jj-aoc.rkt"
         threading
         memoize
         algorithms
         list-utils)

(define data (port->lines (open-day 14 2021)))

(define (starting-polymer d)
  (~> d first string->list (sliding 2 1)))

(define (first-char d)
  (first (first (starting-polymer d))))

(define (starting-counts d)
  (~> d first frequencies hash->list make-hash))

(define (starting-pairs d)
  (~>> d (drop _ 2) (map (λ~> (substring 0 2) string->list))))

(define (new-pairs d)
  (~>> d
       (drop _ 2)
       (map (λ~> (string-replace " -> " "")
                 string->list
                 ((match-lambda
                    [(list a b c) (list a c b)])
                  _)
                 (sliding 2 1)))))

(define (transform d)
  (~>> (map list (starting-pairs d) (new-pairs d)) (append*) (apply hash)))

(define transformation (transform data))

(define/memo (get-count polymer times)
             (match times
               [0
                (for/fold ([counts (hash)]) ([pair (in-list polymer)])
                  (hash-update counts (second pair) add1 0))]
               [_
                (for*/fold ([counts (hash)])
                           ([pair (in-list polymer)]
                            [(c n) (in-hash (get-count (hash-ref transformation pair) (sub1 times)))])
                  (hash-update counts c (λ~> (+ n)) 0))]))

;; part 1
(define (process-polymer d n)
  (~> d
      starting-polymer
      (get-count _ n)
      (hash-update _ (first-char d) add1 0)
      hash-values
      (sort >)
      ((λ (l) (- (first l) (last l))))))

(process-polymer data 10)

;; part 2
(process-polymer data 40)

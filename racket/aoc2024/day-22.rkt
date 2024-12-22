#lang racket

(require advent-of-code
         algorithms
         racket/hash
         threading)

(define initial-seeds
  (~> (fetch-aoc-input (find-session) 2024 22 #:cache #true)
      (string-split "\n")
      (map string->number _)))

(define (prune secret)
  (modulo secret 16777216))

(define (mix value secret)
  (bitwise-xor value secret))

(define (evolve secret)
  (define step-1 (~> secret (* 64) (mix secret) prune))
  (define step-2 (~> step-1 (quotient 32) (mix step-1) prune))
  (~> step-2 (* 2048) (mix step-2) prune))

;; part 1
(for/sum ([seed (in-list initial-seeds)])
         (for/fold ([next seed]) ([_ (in-range 2000)])
           (evolve next)))

(define (generate-prices seed [index 2000] [acc '()])
  (cond
    [(zero? index) (reverse acc)]
    [else (generate-prices (evolve seed) (sub1 index) (cons (modulo seed 10) acc))]))

(define (generate-signals prices)
  (~> prices (drop 2) (sliding 2) (map (curry apply -) _) (sliding 4)))

(define (make-buyer-stats seed)
  (define prices (generate-prices seed))
  (for/hash ([price (in-list (reverse prices))]
             [signal (in-list (reverse (generate-signals prices)))])
    (values signal price)))

;; part 2
(for/fold ([all-stats (hash)]
           #:result (~> all-stats hash->list (argmax cdr _) cdr))
          ([seed (in-list initial-seeds)])
  (define stats (make-buyer-stats seed))
  (hash-union all-stats stats #:combine/key (λ (_ a b) (+ a b))))

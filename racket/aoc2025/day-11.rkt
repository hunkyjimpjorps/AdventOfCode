#lang racket

(require advent-of-code
         algorithms
         memo
         threading)

(define GRAPH
  (for/hash ([line (in-lines (open-aoc-input (find-session) 2025 11 #:cache #true))])
    (define nodes (~> line (string-split #rx":? ") (map string->symbol _)))
    (values (first nodes) (rest nodes))))

(define/match (count-paths _pair)
  [((list from to)) (do-count-paths from to 0)])

(define/memoize (do-count-paths from to n)
                (cond
                  [(equal? from to) 1]
                  [else
                   (for/fold ([acc n]) ([neighbor (hash-ref GRAPH from '())])
                     (+ acc (do-count-paths neighbor to n)))]))

;; part 1
(count-paths '(you out))

;; part 2
(+ (~> '(svr fft dac out) (sliding 2) (map count-paths _) (apply * _)))

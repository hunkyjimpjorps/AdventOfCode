#lang racket

(require advent-of-code
         threading
         algorithms
         memoize)

;; part 1
(define adapters
  (~> (fetch-aoc-input (find-session) 2020 10)
      (string-split "\n")
      (map string->number _)
      (sort <)
      ((λ (xs) (flatten (list 0 xs (+ 3 (last xs))))))))

(~>> adapters
     (sliding _ 2)
     (map (match-lambda
            [(list b a) (- a b)]))
     (group-by identity)
     (map length)
     (apply *))

;; part 2
(define subpaths
  (for*/hash ([adapter (in-list adapters)])
    (define predecessor-candidates (inclusive-range (+ 1 adapter) (+ 3 adapter)))
    (values adapter (filter (λ (p) (member p adapters)) predecessor-candidates))))

(define/memo (find-paths from to)
             (define paths (hash-ref subpaths from 'failed))
             (match paths
               ['failed 0]
               [(list-no-order (== to) _ ...) 1]
               [ts (for/sum ([t (in-list ts)]) (find-paths t to))]))

(find-paths (first adapters) (last adapters))

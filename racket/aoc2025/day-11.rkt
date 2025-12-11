#lang racket

(require advent-of-code
         algorithms
         graph
         memoize
         threading)

(define GRAPH
  (unweighted-graph/adj
   (for/list ([line (in-lines (open-aoc-input (find-session) 2025 11 #:cache #true))])
     (string-split line #rx":? "))))

(define/match (count-paths _pair)
  [((list from to)) (do-count-paths from to 0)])

(define/memo (do-count-paths from to n)
             (cond
               [(equal? from to) 1]
               [else
                (for/fold ([acc n]) ([neighbor (get-neighbors GRAPH from)])
                  (+ acc (do-count-paths neighbor to n)))]))

;; part 1
(count-paths '("you" "out"))

;; part 2
(~> (list "svr" "fft" "dac" "out") (sliding 2) (map count-paths _) (apply * _))

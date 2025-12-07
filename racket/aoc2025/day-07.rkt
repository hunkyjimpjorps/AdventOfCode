#lang racket

(require advent-of-code
         threading
         fancy-app
         "utils/posn.rkt")

(define input (string->posn-grid (fetch-aoc-input (find-session) 2025 7 #:cache #true)))

(define start
  (for/first ([(k v) (in-dict input)]
              #:when (equal? v #\S))
    k))

(define (trace-beams [beams (hash start 1)] [room input] [hits 0])
  (define-values (new-beams new-hits)
    (for/fold ([acc (hash)]
               [cnt hits])
              ([(b-posn b-paths) (in-hash beams)])
      (define next-posn (posn-add b-posn (Posn 0 2)))
      (match (hash-ref room next-posn #f)
        [#\. (values (hash-update acc next-posn (+ b-paths _) 0) cnt)]
        [#\^
         (values (~> acc
                     (hash-update (posn-add next-posn (Posn 1 0)) (+ b-paths _) 0)
                     (hash-update (posn-add next-posn (Posn -1 0)) (+ b-paths _) 0))
                 (add1 cnt))]
        [#f (values acc cnt)])))
  (if (dict-empty? new-beams)
      (values hits (apply + (hash-values beams)))
      (trace-beams new-beams room new-hits)))

;; parts 1 and 2
(trace-beams)

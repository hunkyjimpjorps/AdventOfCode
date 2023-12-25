#lang racket

(require advent-of-code
         threading)

(struct exits (left right) #:transparent)

(match-define (list raw-directions raw-maze)
  (~> (fetch-aoc-input (find-session) 2023 8 #:cache #true) (string-split "\n\n")))

(define directions (string->list raw-directions))

(define maze
  (for/hash ([line (in-list (string-split raw-maze "\n"))])
    (match (regexp-match #rx"(...) = \\((...), (...)\\)" line)
      [(list _ name left right) (values name (exits left right))])))

(define (to-next-node start end dirs maze)
  (for/fold ([current start]
             [acc 0]
             #:result acc)
            ([dir (in-cycle dirs)])
    #:break (string-suffix? current end)
    (define node (hash-ref maze current))
    (case dir
      [(#\L) (values (exits-left node) (add1 acc))]
      [(#\R) (values (exits-right node) (add1 acc))])))

;; part 1
(to-next-node "AAA" "ZZZ" directions maze)

;; part 2
(for/lists (ns #:result (apply lcm ns))
           ([start (in-list (hash-keys maze))]
            #:when (string-suffix? start "A"))
  (to-next-node start "Z" directions maze))

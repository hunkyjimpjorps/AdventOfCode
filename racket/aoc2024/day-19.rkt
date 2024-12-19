#lang racket

(require advent-of-code
         threading
         memo)

(match-define (list raw-towels raw-targets)
  (~> (fetch-aoc-input (find-session) 2024 19 #:cache #true) (string-split "\n\n")))

(define towels (string-split raw-towels ", "))
(define targets (string-split raw-targets "\n"))

(define/memoize (count-pattern stem)
                #:hash hash
                (cond
                  [(not (non-empty-string? stem)) 1]
                  [else
                   (for/sum ([towel (in-list towels)] #:when (string-prefix? stem towel))
                            (count-pattern (string-trim stem towel #:right? #f)))]))

;; part 1
(for/sum ([target (in-list targets)] #:unless (zero? (count-pattern target))) 1)

;; part 2
(for/sum ([target (in-list targets)]) (count-pattern target))

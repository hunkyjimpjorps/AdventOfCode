#lang racket
(require advent-of-code
         list-utils
         threading
         racket/hash)

(define fish-data
  (~> (open-aoc-input (find-session) 2021 6 #:cache (string->path "./cache"))
      port->string
      string-trim
      (string-split ",")
      (map string->number _)))

(define (simulate-fish time-period)
  (for/fold ([state (frequencies fish-data)] #:result (~> state hash-values (apply + _)))
            ([day (inclusive-range 1 time-period)])
    (define day-older-fish
      (for/hash ([(days pop) (in-hash state)])
        (values (sub1 days) pop)))
    (define breeding-fish (hash-ref day-older-fish -1 0))
    (hash-union (hash-remove day-older-fish -1) (hash 8 breeding-fish 6 breeding-fish) #:combine +)))

;; part 1
(simulate-fish 80)

;; part 2
(simulate-fish 256)

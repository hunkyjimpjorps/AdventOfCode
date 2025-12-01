#lang racket

(require advent-of-code
         threading)

(define data
  (for/list ([line (~> (fetch-aoc-input (find-session) 2025 1 #:cache #true) (string-split "\n"))])
    (define n (string->number (substring line 1)))
    (if (string-prefix? line "L")
        (- n)
        n)))

;; part 1
(for/fold ([pointer 50]
           [acc 0]
           #:result acc)
          ([spin data])
  (define new-pointer (+ pointer spin))
  (values new-pointer
          (if (zero? (modulo new-pointer 100))
              (add1 acc)
              acc)))

;; part 2
(for/fold ([pointer 50]
           [acc 0]
           #:result acc)
          ([spin data])
  (define new-pointer (+ pointer spin))
  (define spin-range (rest (inclusive-range pointer new-pointer (sgn spin))))
  (values new-pointer (+ acc (count (λ (n) (zero? (modulo n 100))) spin-range))))

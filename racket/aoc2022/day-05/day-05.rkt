#lang racket

(require advent-of-code
         threading
         (only-in relation ->string ->list ->number)
         (only-in algorithms chunks-of))

(define data (~> (fetch-aoc-input (find-session) 2022 5) (string-split "\n")))

(struct instruction (n from to))

(define crates-list
  (~>> data
       (take _ 8)
       (map (λ~>> ->list))
       (apply map list _)
       rest
       (chunks-of _ 4)
       (map (λ~> first ->string string-trim ->list) _)))

(define crates
  (for/hash ([c (in-list crates-list)] [i (in-naturals 1)])
    (values i c)))

(define (parse-instruction str)
  (match str
    [(regexp #px"move (\\d+) from (\\d) to (\\d)" (list _ n from to))
     (instruction (->number n) (->number from) (->number to))]))

(define instructions (~>> data (drop _ 10) (map parse-instruction)))

(define (find-crate-message cs [reverse-function reverse])
  (for/fold ([current-crates cs]
             #:result (~>> (hash-values current-crates) (map first) (apply string)))
            ([i (in-list instructions)])
    (match-define (instruction n from to) i)
    (define taken (~> (hash-ref current-crates from) (take _ n) reverse-function))
    (~> current-crates
        (hash-update _ from (λ (v) (drop v n)))
        (hash-update _ to (λ (v) (append taken v))))))

;; part 1
(find-crate-message crates)

;; part 2
(find-crate-message crates identity)

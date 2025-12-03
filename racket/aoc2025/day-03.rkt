#lang racket

(require advent-of-code
         threading)

(struct Battery (joltage index))

(define battery-packs
  (for/list ([battery-pack (~> (fetch-aoc-input (find-session) 2025 3 #:cache #true)
                               (string-split "\n"))])
    (~> (for/list ([ch (in-string battery-pack)]
                   [i (in-naturals)])
          (Battery (string->number (string ch)) i))
        (sort < #:key Battery-index)
        (sort > #:key Battery-joltage))))

(define PACK-LENGTH (length (first battery-packs)))

(define (get-best-combo batteries remaining [acc 0])
  (cond
    [(zero? remaining) acc]
    [else
     (define next (findf (λ (b) (>= (- PACK-LENGTH (Battery-index b)) remaining)) batteries))
     (define candidates (filter (λ (b) (> (Battery-index b) (Battery-index next))) batteries))
     (get-best-combo candidates (sub1 remaining) (+ (* 10 acc) (Battery-joltage next)))]))

(define (get-total-joltage size)
  (for/sum ([battery-pack (in-list battery-packs)]) (get-best-combo battery-pack size)))

;; part 1
(get-total-joltage 2)

;; part 2
(get-total-joltage 12)

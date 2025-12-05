#lang racket

(require advent-of-code
         threading)

(struct Range (from to) #:transparent)

(match-define (list raw-ranges raw-ingredients)
  (string-split (fetch-aoc-input (find-session) 2025 5 #:cache #true) "\n\n"))

(define ranges
  (~> (for/list ([line (in-list (string-split raw-ranges))])
        (~> line (string-split "-") (map string->number _) (apply Range _)))
      (sort < #:key Range-from)))

(define ingredients (~> raw-ingredients string-split (map string->number _)))

;; part 1
(define (fresh? i)
  (for/or ([r (in-list ranges)])
    (<= (Range-from r) i (Range-to r))))

(count fresh? ingredients)

;; part 2
(define (scan-ranges rs [prev-to 0] [acc 0])
  (match rs
    ['() acc]
    [(list* (Range _ (? (λ~> (<= prev-to)))) rest) (scan-ranges rest prev-to acc)]
    [(list* (Range (? (λ~> (<= prev-to))) to) rest) (scan-ranges rest to (+ acc to (- prev-to)))]
    [(list* (Range from to) rest) (scan-ranges rest to (+ acc 1 to (- from)))]))

(scan-ranges ranges)

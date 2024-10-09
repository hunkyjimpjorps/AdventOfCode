#lang rackjure

(define first-numbers '(2 20 0 4 1 17))

(define number-hash
  (for/hash ([(xs i) (in-indexed (drop-right first-numbers 1))])
    (values xs (add1 i))))

(define starting-round (~> number-hash hash-values (apply max _) (+ 2)))

(define (find-spoken-number-at end)
  (for/fold ([ns number-hash] [previous-number (last first-numbers)] #:result previous-number)
            ([rnd (inclusive-range starting-round end)])
    (define next-spoken-number
      (match (ns previous-number)
        [#f 0]
        [n (- (sub1 rnd) n)]))
    (values (ns previous-number (sub1 rnd)) next-spoken-number)))

(find-spoken-number-at 2020)

(find-spoken-number-at 30000000)
#lang racket

(require advent-of-code
         relation
         threading
         rebellion/base/range)

(struct field-rule (name range1 range2) #:transparent)

(define (make-lines strs)
  (string-split strs "\n"))
(define (seperate-fields strs)
  (~>> (string-split strs ",") (map ->number)))

(define (process-rules str)
  (match str
    [(regexp
      #px"(.+): (\\d+)-(\\d+) or (\\d+)-(\\d+)"
      (list _ name (app ->number min1) (app ->number max1) (app ->number min2) (app ->number max2)))
     (field-rule name (closed-range min1 max1) (closed-range min2 max2))]))

(match-define (list (app (λ~>> make-lines (map process-rules)) ticket-rules)
                    (app (λ~>> make-lines second seperate-fields) your-ticket)
                    (app (λ~>> make-lines rest (map seperate-fields)) other-tickets))
  (~> (fetch-aoc-input (find-session) 2020 16) (string-split "\n\n")))

(define (ticket-scanning-error-rate ticket rules)
  (for/sum ([ticket-field (in-list ticket)]
            [ticket-rule (in-list rules)]
            #:do [(match-define (field-rule _ r1 r2) ticket-rule)]
            #:unless (or (range-contains? r1 ticket-field) (range-contains? r2 ticket-field)))
           ticket-field))

(for/sum ([ticket (in-list other-tickets)]) (ticket-scanning-error-rate ticket ticket-rules))
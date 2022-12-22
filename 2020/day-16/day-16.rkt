#lang racket

(require racket/struct
         advent-of-code
         fancy-app
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
  (~> (fetch-aoc-input (find-session) 2020 16 #:cache #true) (string-split "\n\n")))

;; part 1
(define (fails-all-checks? field rules)
  (define rule-list (~>> rules (map (λ~> struct->list rest)) flatten))
  (for/and ([rule (in-list rule-list)])
    (not (range-contains? rule field))))

(define (ticket-scanning-error-rate tickets rules)
  (for*/sum
   ([ticket (in-list tickets)] (field (in-list ticket)) #:when (fails-all-checks? field rules))
   field))

(ticket-scanning-error-rate other-tickets ticket-rules)

;; part 2
(define valid-tickets (filter (ormap (fails-all-checks? _ ticket-rules) _) other-tickets))

(define fields (apply map list valid-tickets))

(for/list ([field (in-list fields)])
  (for*/list (
              [rule (in-list ticket-rules)]
              #:unless (not (or (range-contains? (field-rule-range1 rule) value)
                                (range-contains? (field-rule-range2 rule) value))))
    (field-rule-name rule)))

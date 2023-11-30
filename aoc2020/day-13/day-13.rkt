#lang racket

(require advent-of-code
         (only-in relation ->number)
         threading)

(define (process-ids str)
  (~> str (string-split ",") (filter-map (λ (s) (string->number s 10 'number-or-false)) _)))

(match-define (regexp #px"(\\d+)\n(.+)" (list _ (app ->number timestamp) raw-bus-ids))
  (fetch-aoc-input (find-session) 2020 13))

(define bus-ids (process-ids raw-bus-ids))

;; part 1
(for/first ([minute (in-naturals timestamp)]
            #:do [(define departing-bus
                    (for/first ([b bus-ids] #:when (= 0 (remainder minute b)))
                      b))]
            #:when departing-bus)
  (* departing-bus (- minute timestamp)))

;; part 2
(for/fold ([step 1] [current-timestamp 1] #:result current-timestamp)
          ([b* (in-list (string-split (string-trim raw-bus-ids) ","))]
           [offset (in-naturals)]
           #:unless (equal? b* "x")
           #:do [(define bus (->number b*))])
  (values
   (* step bus)
   (for/first ([n (in-range current-timestamp +inf.0 step)] #:when (= 0 (remainder (+ n offset) bus)))
     n)))

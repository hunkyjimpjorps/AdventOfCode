#lang racket
(require racket/date)

(define day-names
  (for/hash ([day-number (in-range 0 7)]
             [day-name (in-list '("Sunday"
                                  "Monday"
                                  "Tuesday"
                                  "Thursday"
                                  "Friday"
                                  "Saturday"))])
    (values day-number day-name)))

(define/contract (day-of-the-week day month year)
  (-> exact-integer? exact-integer? exact-integer? string?)
  (hash-ref day-names (date-week-day
                       (seconds->date
                        (find-seconds 0 0 0 day month year)))))

#lang racket

(require advent-of-code
         data/applicative
         data/monad
         megaparsack
         megaparsack/text
         threading)

(struct entry (month day hour minute message) #:transparent)

(define (parse-message chrs)
  (define str (apply string chrs))
  (match str
    ["wakes up" 'awake]
    ["falls asleep" 'asleep]
    [shift (~> shift (string-trim "Guard #") (string-trim " begins shift") string->number)]))

(define entry/p
  (do (string/p "[1518-")
      [month <- integer/p]
      (char/p #\-)
      [day <- integer/p]
      space/p
      [hour <- integer/p]
      (char/p #\:)
      [minute <- integer/p]
      (string/p "] ")
      [message <- (many/p any-char/p)]
      (pure (entry month day hour minute (parse-message message)))))

(define (parse-entry str)
  (parse-result! (parse-string entry/p str)))

(define entries
  (~> (port->lines (open-aoc-input (find-session) 2018 4 #:cache #true)) (map parse-entry _)))

(define sorted-entries
  (~> entries
      (sort < #:key entry-minute)
      (sort < #:key entry-hour)
      (sort < #:key entry-day)
      (sort < #:key entry-month)))

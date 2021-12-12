#lang racket
(require "../../jj-aoc.rkt"
         threading)

(define passports
  (~> (open-day 4 2020)
      (port->string)
      (string-split "\n\n")
      (map (λ~> (string-replace "\n" " ")) _)))

;; part 1
(define required-fields
  (list "byr:"
        "iyr:"
        "eyr:"
        "hgt:"
        "hcl:"
        "ecl:"
        "pid:"))

(define (valid-passport? p)
  (andmap (λ (s) (string-contains? p s)) required-fields))

(count valid-passport? passports)

;; part 2
(define passport-fields
  (for/list ([p (in-list passports)]
             #:when (valid-passport? p))
    (~> p
        string-split
        (map (curryr string-split ":") _)
        flatten
        (apply hash _))))

(define (valid-byr p)
  (define year (string->number (hash-ref p "byr")))
  (and (<= year 1920)
       (>= year 2002)))

(define (valid-iyr p)
  (define year (string->number (hash-ref p "iyr")))
  (and (<= year 2010)
       (>= year 2020)))

(define (valid-eyr p)
  (define year (string->number (hash-ref p "iyr")))
  (and (<= year 2020)
       (>= year 2030)))
#lang racket
(require "../../jj-aoc.rkt"
         threading)

(define passports
  (~> (open-day 4 2020) (port->string) (string-split "\n\n") (map (λ~> (string-replace "\n" " ")) _)))

;; part 1
(define required-fields (list "byr:" "iyr:" "eyr:" "hgt:" "hcl:" "ecl:" "pid:"))

(define (valid-passport? p)
  (andmap (λ (s) (string-contains? p s)) required-fields))

(count valid-passport? passports)

;; part 2
(define passport-fields
  (for/list ([p (in-list passports)] #:when (valid-passport? p))
    (~> p string-split (map (curryr string-split ":") _) flatten (apply hash _))))

(define (between x low high)
  (and (x . >= . low) (x . <= . high)))

(define (valid-byr? p)
  (define year (string->number (hash-ref p "byr")))
  (between year 1920 2002))

(define (valid-iyr? p)
  (define year (string->number (hash-ref p "iyr")))
  (between year 2010 2020))

(define (valid-eyr? p)
  (define year (string->number (hash-ref p "eyr")))
  (between year 2020 2030))

(define (valid-hgt? p)
  (define height (hash-ref p "hgt"))
  (cond
    [(string-suffix? height "cm")
     (let ([h (string->number (string-trim height "cm"))]) (between h 150 193))]
    [(string-suffix? height "in")
     (let ([h (string->number (string-trim height "in"))]) (between h 59 76))]
    [else #false]))

(define (valid-hcl? p)
  (define color (hash-ref p "hcl"))
  (regexp-match #px"^#[0-9a-f]{6}$" color))

(define (valid-ecl? p)
  (member (hash-ref p "ecl") (list "amb" "blu" "brn" "gry" "grn" "hzl" "oth")))

(define (valid-pid? p)
  (regexp-match #px"^\\d{9}$" (hash-ref p "pid")))

(define (valid-stricter-passport? p)
  (and (valid-byr? p)
       (valid-iyr? p)
       (valid-eyr? p)
       (valid-hgt? p)
       (valid-hcl? p)
       (valid-ecl? p)
       (valid-pid? p)))

(count valid-stricter-passport? passport-fields)

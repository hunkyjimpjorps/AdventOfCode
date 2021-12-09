#lang racket
(require "../../jj-aoc.rkt"
         threading
         file/md5)

(define secret-key (~> (open-day 4 2015)
                       port->string
                       string-trim))

(define (find-n-zeroes n)
  (for/first ([i (in-naturals)]
              #:when (~>> i
                          (~a secret-key)
                          md5
                          bytes->string/utf-8
                          (string-prefix? _ (make-string n #\0))))
    i))

;; part 1
(time (find-n-zeroes 5))

;; part 2
(time (find-n-zeroes 6))
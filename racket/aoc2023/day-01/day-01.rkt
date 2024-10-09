#lang racket

(require advent-of-code
         threading)

(define calibration-values (fetch-aoc-input (find-session) 2023 1))

(define (to-number str)
  (match (string->number str)
    [#false (hash-ref word-to-digit str)]
    [n n]))

(define (parse-calibration-value v valid)
  (for/fold ([acc '()] [value v] #:result (+ (to-number (first acc)) (* 10 (to-number (last acc)))))
            ([_ (in-naturals)])
    #:break (equal? value "")
    (let ([possible-prefix (findf (curry string-prefix? value) valid)])
      (if possible-prefix
          (values (cons possible-prefix acc) (substring value 1))
          (values acc (substring value 1))))))

(define (total-calibration input valid)
  (~> input
      (string-trim)
      (string-split "\n")
      (map (λ~> (parse-calibration-value valid)) _)
      (apply + _)))

;; part 1

(define valid-for-part-1 (~> (range 1 10) (map ~a _)))
(total-calibration calibration-values valid-for-part-1)

;; part 2
(define word-to-digit
  (hash "one" 1 "two" 2 "three" 3 "four" 4 "five" 5 "six" 6 "seven" 7 "eight" 8 "nine" 9))
(define valid-for-part-2 (append valid-for-part-1 (hash-keys word-to-digit)))
(total-calibration calibration-values valid-for-part-2)

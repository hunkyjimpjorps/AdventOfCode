#lang racket

(require math/statistics
         threading
         "../../jj-aoc.rkt")

(define chunks
  (port->lines (open-day 10 2021)))

(define (opening-bracket? c)
  (member c (string->list "([{<")))

(define (matching-brackets? c-left c-right)
  (member (string c-left c-right) '("()" "[]" "{}" "<>")))

(define (parse-brackets lst [acc '()])
  (cond
    [(empty? lst) acc]
    [(opening-bracket? (first lst))
     (parse-brackets (rest lst) (cons (first lst) acc))]
    [(matching-brackets? (first acc) (first lst))
     (parse-brackets (rest lst) (rest acc))]
    [else (get-score (first lst))]))

;; part 1
(define (get-score c)
  (match (string c)
    [")" 3]
    ["]" 57]
    ["}" 1197]
    [">" 25137]))

(define (score-invalid-string chunk)
  (match (parse-brackets (string->list chunk))
    [(? list?) 0]
    [n n]))

(for/sum ([chunk (in-list chunks)]) (score-invalid-string chunk))

;; part 2
(define (completion-score lst)
  (for/fold ([score 0])
            ([c (in-list lst)])
    (define val
      (match (string c)
        ["(" 1]
        ["[" 2]
        ["{" 3]
        ["<" 4]))
    (+ (* 5 score) val)))

(define (score-incomplete-string chunk)
  (match (parse-brackets (string->list chunk))
    [(? list? lst) (completion-score lst)]
    [n 0]))

(~>> (for*/list ([chunk (in-list chunks)]
                 [score (in-value (score-incomplete-string chunk))]
                 #:when (> score 0))
       score)
     (median < ))
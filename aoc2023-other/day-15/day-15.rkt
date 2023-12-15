#lang racket

(require advent-of-code
         threading)

(define input
  (~> (fetch-aoc-input (find-session) 2023 15 #:cache #true) string-trim (string-split ",")))

(define (hash-algorithm str)
  (for/fold ([acc 0]) ([c (in-string str)])
    (~> c char->integer (+ acc) (* 17) (modulo _ 256))))

;; part 1
(for/sum ([code (in-list input)]) (hash-algorithm code))

;; part 2
(define (remove-lens boxes label)
  (hash-update boxes
               (hash-algorithm label)
               (λ (lens-set) (remove label lens-set (λ (rem l) (equal? rem (car l)))))
               '()))

(define (insert-lens boxes label focal)
  (define new-lens (cons label focal))
  (hash-update boxes
               (hash-algorithm label)
               (λ (lens-set)
                 (if (assoc label lens-set)
                     (map (λ (pair) (if (equal? (car pair) label) new-lens pair)) lens-set)
                     (append lens-set (list new-lens))))
               (list new-lens)))

(define (focusing-power boxes)
  (for*/sum ([(box-number lenses) (in-hash boxes)] [(lens order) (in-indexed lenses)])
    (match-define (cons _ focal) lens)
    (* (add1 box-number) (add1 order) (string->number focal))))

(for/fold ([boxes (hash)] #:result (focusing-power boxes)) ([code (in-list input)])
  (match code
    [(regexp #rx"(.*)=(.*)" (list _ label focal)) (insert-lens boxes label focal)]
    [(regexp #rx"(.*)-" (list _ label)) (remove-lens boxes label)]))

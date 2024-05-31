#lang racket

(require advent-of-code
         threading)

(define starting-chain
  (~> (fetch-aoc-input (find-session) 2018 5 #:cache #true) string-trim string->list))

(define (reactive-pair? ch1 ch2)
  (and (equal? (char-downcase ch1) (char-downcase ch2)) (not (equal? ch1 ch2))))

(define (remove-reactive-pairs chs [acc '()])
  (match chs
    [(list* ch1 ch2 rest-chs)
     #:when (reactive-pair? ch1 ch2)
     (remove-reactive-pairs rest-chs acc)]
    [(list* ch rest-chs) (remove-reactive-pairs rest-chs (cons ch acc))]
    [(list) (reverse acc)]))

(define (keep-removing-reactive-pairs chs)
  (define chs* (remove-reactive-pairs chs))
  (if (equal? chs chs*) (length chs) (keep-removing-reactive-pairs chs*)))

;; part 1
(keep-removing-reactive-pairs starting-chain)

;; part 2
(~>> (for/list ([letter (in-string "abcdefghijklmnopqrstuvwxyz")])
       (define tweaked-chain (filter (λ (c) (not (equal? (char-downcase c) letter))) starting-chain))
       (keep-removing-reactive-pairs tweaked-chain))
     (apply min))

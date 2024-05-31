#lang racket

(require advent-of-code
         threading)

(define ids (port->lines (open-aoc-input (find-session) 2018 2 #:cache #true)))

;; part 1
(define (make-baskets str)
  (for/fold ([baskets (hash)]) ([ch (in-string str)])
    (hash-update baskets ch add1 0)))

(define (has-count n ht)
  (member n (hash-values ht)))

(for/fold ([two 0] [three 0] #:result (* two three)) ([id (in-list ids)])
  (define baskets (make-baskets id))
  (values (if (has-count 2 baskets) (add1 two) two) (if (has-count 3 baskets) (add1 three) three)))

;; part 2
(define (string-difference str1 str2)
  (for/sum ([ch1 (in-string str1)] [ch2 (in-string str2)]) (if (equal? ch1 ch2) 0 1)))

(for*/first ([id1 (in-list ids)] [id2 (in-list ids)] #:when (= 1 (string-difference id1 id2)))
  (~>> (for/list ([ch1 (in-string id1)] [ch2 (in-string id2)] #:when (equal? ch1 ch2))
         ch1)
       (apply string)))

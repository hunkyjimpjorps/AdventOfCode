#lang racket

(require advent-of-code)

(define raw-packets
  (parameterize ([current-readtable (make-readtable #f #\, #\space #f)])
    (port->list read (open-aoc-input (find-session) 2022 13 #:cache #true))))

(define (compare xs ys)
  (match* (xs ys)
    [('() (list* _)) #true]
    [((list* _) '()) #false]
    [((list* _same x-rest) (list* _same y-rest)) (compare x-rest y-rest)]
    [((list* (? integer? x) _) (list* (? integer? y) _)) (< x y)]
    [((list* (? list? xs*) _) (list* (? list? ys*) _)) (compare xs* ys*)]
    [(xs (list* (? integer? y) y-rest)) (compare xs (cons (list y) y-rest))]
    [((list* (? integer? x) x-rest) ys) (compare (cons (list x) x-rest) ys)]))

;; part 1
(for/sum ([i (in-naturals 1)] [packet (in-slice 2 raw-packets)] #:when (apply compare packet)) i)

;; part 2
(define divider-packets (list '((2)) '((6))))
(define amended-packets (append divider-packets raw-packets))

(for/product ([i (in-naturals 1)] [packet (in-list (sort amended-packets compare))]
                                  #:when (member packet divider-packets))
             i)

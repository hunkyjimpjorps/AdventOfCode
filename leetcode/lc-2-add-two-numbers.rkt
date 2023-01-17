#lang racket
; Definition for singly-linked list:


; val : integer?
; next : (or/c list-node? #f)
(struct list-node
  (val next) #:mutable #:transparent)

; constructor
(define (make-list-node val [next-node #f])
  (list-node val next-node))


(define/contract (add-two-numbers l1 l2)
  (-> (or/c list-node? #f) (or/c list-node? #f) (or/c list-node? #f))
  (define (process-list node [acc '()])
    (if (list-node-next node)
        (process-list (list-node-next node) (cons (list-node-val node) acc))
        (cons (list-node-val node) acc)))
  (define sum-of-lists (+ (string->number (apply ~a (process-list l1)))
                          (string->number (apply ~a (process-list l2)))))
  (define sum-list-digits
    (reverse
     (map (λ (x) (string->number (string x)))
          (string->list (number->string sum-of-lists)))))
  (define (build-list l)
    (if (empty? l)
        #f
        (make-list-node (car l) (build-list (cdr l)))))
  (build-list sum-list-digits))

(define list1 (make-list-node 2 (make-list-node 4 (make-list-node 3))))
(define list2 (make-list-node 5 (make-list-node 6 (make-list-node 4))))
(add-two-numbers list1 list2)
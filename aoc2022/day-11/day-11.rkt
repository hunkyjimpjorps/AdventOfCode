#lang racket
(require threading)

(struct monkey ([items #:mutable] operation modulus yes no))

;; really don't feel like parsing the input today
(define monkeys-list
  (list (cons 0 (monkey '(97 81 57 57 91 61)
                        (λ (n) (* n 7))
                        11 5 6))
        (cons 1 (monkey '(88 62 68 90)
                        (λ (n) (* n 17))
                        19 4 2))
        (cons 2 (monkey '(74 87)
                        (λ (n) (+ n 2))
                        5 7 4))
        (cons 3 (monkey '(53 81 60 87 90 99 75)
                        (λ (n) (+ n 1))
                        2 2 1))
        (cons 4 (monkey '(57)
                        (λ (n) (+ n 6))
                        13 7 0))
        (cons 5 (monkey '(54 84 91 55 59 72 75 70)
                        (λ (n) (* n n))
                        7 6 3))
        (cons 6 (monkey '(95 79 79 68 78)
                        (λ (n) (+ n 3))
                        3 1 3))
        (cons 7 (monkey '(61 97 67)
                        (λ (n) (+ n 4))
                        17 0 5))))

(define monkey-lcm (~> monkeys-list (map (λ~> cdr monkey-modulus) _) (apply lcm _)))

;; part 1
(define monkeys-count-pt1 (make-hash))
(define monkeys-hash-pt1 (make-hash monkeys-list))

(for
    ([rnd (in-range 20)])
  (for
      ([turn (inclusive-range 0 7)])
    (match-define (monkey items op modulus yes no) (hash-ref monkeys-hash-pt1 turn))
    (for ([i (in-list items)])
      (define i* (quotient (op i) 3))
      (define m (if (= 0 (modulo i* modulus)) yes no))
      (match-define (monkey items* op* modulus* yes* no*) (hash-ref monkeys-hash-pt1 m))
      (hash-update! monkeys-count-pt1 turn add1 0)
      (hash-set! monkeys-hash-pt1
                 m
                 (monkey (append items* (list i*)) op* modulus* yes* no*)))
    (hash-set! monkeys-hash-pt1 turn (monkey '() op modulus yes no))))

(~> monkeys-count-pt1
    hash->list
    (sort _ > #:key cdr)
    (take _ 2)
    (map cdr _)
    (apply * _))

;; part 2
(define monkeys-count-pt2 (make-hash))
(define monkeys-hash-pt2 (make-hash monkeys-list))

(for
    ([rnd (in-range 10000)])
  (for
      ([turn (inclusive-range 0 7)])
    (match-define (monkey items op modulus yes no) (hash-ref monkeys-hash-pt2 turn))
    (for ([i (in-list items)])
      (define i* (op i))
      (define m (if (= 0 (modulo i* modulus)) yes no))
      (match-define (monkey items* op* modulus* yes* no*) (hash-ref monkeys-hash-pt2 m))
      (hash-update! monkeys-count-pt2 turn add1 0)
      (hash-set! monkeys-hash-pt2
                 m
                 (monkey (append items* (list (remainder i* monkey-lcm))) op* modulus* yes* no*)))
    (hash-set! monkeys-hash-pt2 turn (monkey '() op modulus yes no))))

(~> monkeys-count-pt2
    hash->list
    (sort _ > #:key cdr)
    (take _ 2)
    (map cdr _)
    (apply * _))
#lang racket
(define (summary-ranges nums)
  (define range-pairs
    (cond
      [(empty? nums) '()]
      [(empty? (cdr nums)) (list (cons (car nums) (car nums)))]
      [else (for/fold ([ranges '()]
                       [open-pair (first nums)]
                       [prev-num (first nums)]
                       #:result (append ranges (list (cons open-pair prev-num))))
                      ([i (cdr nums)])
              (cond [(= (add1 prev-num) i)
                     (values ranges
                             open-pair
                             i)]
                    [else
                     (values (append ranges (list (cons open-pair prev-num)))
                             i
                             i)]))]))
  (for/list ([p (in-list range-pairs)])
    (cond [(= (car p) (cdr p)) (format "~a" (car p))]
          [else (format "~a->~a" (car p) (cdr p))])))

(summary-ranges '(0 1 2 4 5 7))
(summary-ranges '(0 2 3 4 6 8 9))
(summary-ranges '())
(summary-ranges '(0))
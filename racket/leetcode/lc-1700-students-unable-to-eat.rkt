#lang racket
(define/contract (count-students students sandwiches)
  (-> (listof exact-integer?) (listof exact-integer?) exact-integer?)
  (for/fold ([sandwich-pile sandwiches]
             [student-line students]
             [remaining-students (length students)]
             [break? #false]
             #:result remaining-students)
            ([i (in-naturals)]
             #:break break?)
    (cond [(and (empty? sandwich-pile)
                (empty? student-line))
           (values void
                   void
                   remaining-students
                   #true)]
          [(equal? (car sandwich-pile)
                   (car student-line))
           (values (cdr sandwich-pile)
                   (cdr student-line)
                   (sub1 remaining-students)
                   #false)]
          [(and (not (equal? (list (car sandwich-pile))
                        (remove-duplicates student-line)))
                (= 1 (length (remove-duplicates student-line))))
           (values void
                   void
                   remaining-students
                   #true)]
          [else
           (values sandwich-pile
                   (append (cdr student-line) (list (car student-line)))
                   remaining-students
                   #false)])))

(count-students '(1 1 0 0) '(0 1 0 1))

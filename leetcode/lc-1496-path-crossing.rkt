#lang racket
(define/contract (is-path-crossing path)
  (-> string? boolean?)
  (for/fold ([current-x 0]
             [current-y 0]
             [trail (set '(0 0))]
             [check #false]
             #:result check)
            ([step (in-list (string->list path))]
             #:break check)
    (let*-values
        ([(new-x new-y)
          (case step
            [(#\N) (values current-x (add1 current-y))]
            [(#\S) (values current-x (sub1 current-y))]
            [(#\E) (values (add1 current-x) current-y)]
            [(#\W) (values (sub1 current-x) current-y)])]
         [(new-trail-point) (list new-x new-y)])
      (cond [(set-member? trail new-trail-point)
             (values void void void #true)]
            [else
             (values new-x
                     new-y
                     (set-add trail new-trail-point)
                     #false)]))))
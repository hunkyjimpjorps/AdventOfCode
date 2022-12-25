#lang racket

(require advent-of-code
         threading)

(define initial-opcodes
  (parameterize ([current-readtable (make-readtable #f #\, #\space #f)])
    (port->list read (open-aoc-input (find-session) 2019 2 #:cache #true))))

;; part 1
(define (edit-opcode ocs oc-1 oc-2)
  (~> ocs (list-set 1 oc-1) (list-set 2 oc-2)))

(define (run-intcode ocs)
  (for/fold ([ocs ocs] #:result (car ocs))
            ([pointer (in-range 0 (length initial-opcodes) 4)] #:break (= 99 (list-ref ocs pointer)))
    (define op
      (match (list-ref ocs pointer)
        [1 +]
        [2 *]))
    (list-set ocs
              (list-ref ocs (+ 3 pointer))
              (op (list-ref ocs (list-ref ocs (+ 1 pointer)))
                  (list-ref ocs (list-ref ocs (+ 2 pointer)))))))

(~> initial-opcodes (edit-opcode 12 2) run-intcode)

;; part 2
(for*/first ([noun (inclusive-range 0 99)]
             [verb (inclusive-range 0 99)]
             #:when (~> initial-opcodes (edit-opcode noun verb) run-intcode (= 19690720)))
  (+ (* 100 noun) verb))

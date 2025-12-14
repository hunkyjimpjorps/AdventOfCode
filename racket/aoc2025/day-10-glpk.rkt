#lang racket

(require advent-of-code
         threading
         glpk)

(struct Machine (lights buttons joltages) #:transparent)

(define machines
  (for/list ([line (string-split (fetch-aoc-input (find-session) 2025 10 #:cache #true) "\n")])
    (match-define (list raw-lights raw-buttons ... raw-joltages) (string-split line " "))
    (Machine
     (for/set ([(ch i) (in-indexed (string-trim raw-lights #px"[\\[\\]]"))]
               #:when (equal? ch #\#))
       i)
     (for/list ([buttons (in-list raw-buttons)])
       (~> buttons (string-trim #px"[\\(\\)]") (string-split ",") (map string->number _) (list->set)))
     (~> raw-joltages (string-trim #px"[{}]") (string-split ",") (map string->number _)))))

(define (make-var prefix n)
  (string->symbol (~a prefix n)))

(define (objective machine)
  (match-define (Machine _ buttons _) machine)
  (cons 0
        (for/list ([x (in-range (length buttons))])
          (list 1 (make-var "x" x)))))

(define (constraints machine)
  (match-define (Machine _ buttons joltages) machine)
  (for/list ([(_ index) (in-indexed joltages)])
    (cons (make-var "j" index)
          (for/list ([(b i) (in-indexed buttons)]
                     #:when (set-member? b index))
            (list 1 (make-var "x" i))))))

(define (bounds machine from to)
  (match-define (Machine _ buttons joltages) machine)
  (append (for/list ([x (in-range (length buttons))])
            (list (make-var "x" x) from to))
          (for/list ([(j i) (in-indexed joltages)])
            (list (make-var "j" i) j j))))

(define (integer-vars machine)
  (match-define (Machine _ buttons _) machine)
  (for/list ([x (in-range (length buttons))])
    (make-var "x" x)))

(for/sum ([machine (in-list machines)])
         (match-define (list _ _ (list* total _))
           (mip-solve (objective machine)
                      'min
                      (constraints machine)
                      (bounds machine 0 'posinf)
                      (integer-vars machine)))
         (println (~a (Machine-joltages machine) "->" (inexact->exact total)))
         (inexact->exact total))

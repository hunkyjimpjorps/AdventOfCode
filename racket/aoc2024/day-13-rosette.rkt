#lang rosette

(require advent-of-code
         threading
         rosette/solver/smt/z3)

(current-solver (z3 #:logic 'QF_LIA))

(struct Machine (a b prize) #:transparent)
(struct Dist (x y) #:transparent)

(define button-re #px"Button .: X\\+(\\d+), Y\\+(\\d+)")
(define prize-re #px"Prize: X=(\\d+), Y=(\\d+)")

(define MACHINES
  (for/list ([machine (string-split (fetch-aoc-input (find-session) 2024 13 #:cache #t) "\n\n")])
    (match-define (list a b prize) (string-split machine "\n"))

    (match-define (list (list (app string->number ax) (app string->number ay)))
      (regexp-match* button-re a #:match-select cdr))
    (match-define (list (list (app string->number bx) (app string->number by)))
      (regexp-match* button-re b #:match-select cdr))
    (match-define (list (list (app string->number px) (app string->number py)))
      (regexp-match* prize-re prize #:match-select cdr))

    (Machine (Dist ax ay) (Dist bx by) (Dist px py))))

(define-symbolic a b integer?)
(assert (positive? a))
(assert (positive? b))

(define (find-price machine)
  (match-define (Machine (Dist ax ay) (Dist bx by) (Dist px py)) machine)

  (define sol
    (solve (begin
             (assert (= px (+ (* ax a) (* bx b))))
             (assert (= py (+ (* ay a) (* by b)))))))
  (cond
    [(unsat? sol) 0]
    [else (evaluate (+ (* 3 a) b) sol)]))

;; part 1
(time (for/sum ([machine (in-list MACHINES)]) (find-price machine)))

;; part 2
(define/match (recalibrate _machine)
  [((Machine a b (Dist prize-x prize-y)))
   (Machine a b (Dist (+ 10000000000000 prize-x) (+ 10000000000000 prize-y)))])

(time (for/sum ([machine (in-list MACHINES)]) (~> machine recalibrate find-price)))

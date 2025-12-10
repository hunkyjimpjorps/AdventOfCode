#lang rosette

(require advent-of-code
         threading
         rosette/solver/smt/z3)

(current-solver (z3 #:path (find-executable-path "z3") #:logic 'QF_LIA))

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

;; part 1

(define (minimize-lights machine)
  (match-define (Machine lights buttons _) machine)
  (for*/first ([n (in-naturals)]
               [bs (in-combinations buttons n)]
               #:when (set-empty? (foldl set-symmetric-difference lights bs)))
    (length bs)))

(~>> machines (map minimize-lights) (apply +))

;; part 2

(define (minimize-presses machine)
  (clear-vc!)
  (match-define (Machine _ buttons joltages) machine)
  (define-symbolic* n integer? #:length (length buttons))

  (define sol
    (optimize #:minimize (list (foldl + 0 n))
              #:guarantee (begin
                            (for ([v (in-list n)])
                              (assert (>= v 0)))
                            (for ([total (in-list joltages)]
                                  [index (in-naturals)])
                              (define valid-n
                                (for/list ([b (in-list buttons)]
                                           [var (in-list n)]
                                           #:when (set-member? b index))
                                  var))
                              (assert (= total (foldl + 0 valid-n)))))))

  (evaluate (foldl + 0 n) sol))

(~>> machines (map minimize-presses) (apply +))

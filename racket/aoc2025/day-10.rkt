#lang racket

(require advent-of-code
         threading
         memo)

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

(for/sum ([machine (in-list machines)])
         (match-define (Machine lights buttons _) machine)
         (for*/first ([n (in-naturals)]
                      [bs (in-combinations buttons n)]
                      #:when (set-empty? (foldl set-symmetric-difference lights bs)))
           (length bs)))

;; part 2

(define (parity xs [acc 0])
  (if (empty? xs)
      acc
      (parity (rest xs) (+ (* 2 acc) (modulo (first xs) 2)))))

(define (make-patterns machine)
  (match-define (Machine _ buttons joltages) machine)

  (define pattern-cost
    (for*/fold ([acc (hash)])
               ([combination-length (in-inclusive-range (length buttons) 0 -1)]
                ; make sure that the shortest combination that gives a particular joltage result
                ; is the one that's recorded in the end by folding from longest to shortest
                [buttons (in-combinations buttons combination-length)])
      (define key
        (hash-values (for*/fold ([acc (for/hash ([k (in-range (length joltages))])
                                        (values k 0))])
                                ([button (in-list buttons)]
                                 [modified (in-set button)])
                       (hash-update acc modified add1))))
      (hash-set acc key combination-length)))

  (for/fold ([acc (hash)]) ([(pattern cost) (in-hash pattern-cost)])
    (hash-update acc (parity pattern) (λ~> (hash-set _ pattern cost)) (hash))))

(define (minimize-presses machine)
  (define parity-pattern-costs (make-patterns machine))
  (define/memoize
   (do-minimize-presses goal)
   (cond
     [(andmap zero? goal) 0]
     [else
      (define pattern-costs (hash-ref parity-pattern-costs (parity goal) (hash)))
      ; if a particular button combination gives us the right parity, subtract it from the goal
      ; divide the remaining goal by half and solve the new smaller goal
      (for/fold ([result 1000])
                ([(pattern cost) (in-hash pattern-costs)]
                 #:when (andmap (λ (p g) (and (<= p g) (= (modulo p 2) (modulo g 2)))) pattern goal))
        (define new-goal (map (λ (p g) (quotient (- g p) 2)) pattern goal))
        (min result (+ cost (* 2 (do-minimize-presses new-goal)))))]))
  (do-minimize-presses (Machine-joltages machine)))

(for/sum ([machine (in-list machines)]) (minimize-presses machine))

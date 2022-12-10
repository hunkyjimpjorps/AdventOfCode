#lang racket

(require advent-of-code
         threading
         fancy-app
         (only-in algorithms chunks-of))

(define/match (process-instruction _)
  [((list "noop")) (list 'noop)]
  [((list "addx" (app string->number val))) (list 'noop (cons 'addx val))])

(define instructions
  (~> (fetch-aoc-input (find-session) 2022 10)
      (string-split "\n")
      (map (λ~> string-split process-instruction) _)
      (apply append _)))

;; part 1
(define interesting-times (inclusive-range 20 220 40))

(define/match (evaluate-instruction _op acc)
  [('noop _) acc]
  [((cons 'addx n) _) (+ acc n)])

(for/fold ([acc 1] [interesting-strengths 0] #:result interesting-strengths)
          ([inst (in-list instructions)] [i (in-naturals 1)])
  (define new-interesting
    (if (member i interesting-times) (+ interesting-strengths (* i acc)) interesting-strengths))
  (values (evaluate-instruction inst acc) new-interesting))

;; part 2
(for/fold ([acc 1] [pixels '()] #:result (~> pixels reverse (chunks-of 40) (map (apply string _) _)))
          ([inst (in-list instructions)] [i (in-naturals)])
  (define new-pixel (if (member (modulo i 40) (list (sub1 acc) acc (add1 acc))) #\█ #\space))
  (values (evaluate-instruction inst acc) (cons new-pixel pixels)))

; for my data set,
; '("███  ████ ████ █  █ ████ ████ █  █  ██  "
;   "█  █    █ █    █ █  █    █    █  █ █  █ "
;   "█  █   █  ███  ██   ███  ███  ████ █  █ "
;   "███   █   █    █ █  █    █    █  █ ████ "
;   "█ █  █    █    █ █  █    █    █  █ █  █ "
;   "█  █ ████ ████ █  █ ████ █    █  █ █  █ ")

#lang racket
(require advent-of-code
         threading
         (only-in awesome-list transpose)
         (only-in algorithms chunks-of))

(define data
  (for/list ([l (in-lines (open-aoc-input (find-session) 2021 4 #:cache (string->path "./cache")))]
             #:unless (equal? l ""))
    l))

(define call-sheet
  (~> data
      car
      (string-split ",")
      (map string->number _)))
(define bingo-cards
  (~> data
      cdr
      (map string-split _)
      (map (λ (row) (map string->number row)) _)
      (chunks-of 5)))

(define test-card (first bingo-cards))

(define (mark-card card call)
  (for/list ([row (in-list card)])
    (for/list ([col (in-list row)])
      (if (eq? col call) 'X col))))

(define (check-card card)
  (for/or ([row (in-sequences card (transpose card))])
    (equal? row '(X X X X X))))

(define (multiply-by-last-call n call)
  (match n
    ['X 0]
    [n (* n call)]))

(define (evaluate-cards cards calls [check (curry ormap check-card)] [exception not])
  (for/fold ([current-cards cards]
             [last-call 0]
             #:result (~> current-cards
                          (findf check-card _)
                          flatten
                          (map (λ (n) (multiply-by-last-call n last-call)) _)
                          (apply + _)))
            ([call (in-list calls)])
    #:break (check current-cards)
    (values (for/list ([card (in-list current-cards)]
                       #:unless (exception card))
              (mark-card card call))
            call)))

;; part 1
(evaluate-cards bingo-cards call-sheet)
;; part 2
(evaluate-cards bingo-cards
                call-sheet
                (λ (cards) (and (= (length cards) 1)
                                (check-card (first cards))))
                check-card)
#lang racket

(require advent-of-code
         algorithms
         memo
         soup-lib
         threading
         "utils/posn.rkt")

(define codes (~> (fetch-aoc-input (find-session) 2024 21 #:cache #true) string-split))

(define (num-to-coord ch)
  (match ch
    [#\7 (Posn 0 1)]
    [#\8 (Posn 0 2)]
    [#\9 (Posn 0 3)]
    [#\4 (Posn 1 1)]
    [#\5 (Posn 1 2)]
    [#\6 (Posn 1 3)]
    [#\1 (Posn 2 1)]
    [#\2 (Posn 2 2)]
    [#\3 (Posn 2 3)]
    [#\0 (Posn 3 2)]
    [#\A (Posn 3 3)]))

(define (dir-to-coord button)
  (match button
    ['up (Posn 0 2)]
    ['push (Posn 0 3)]
    ['left (Posn 1 1)]
    ['down (Posn 1 2)]
    ['right (Posn 1 3)]))

(define (make-move a b lt gt)
  (cond
    [(< a b) (make-list (- b a) lt)]
    [(> a b) (make-list (- a b) gt)]
    [else '()]))

(define (to-next-numeric pts)
  (match-define (list (Posn ar ac) (Posn br bc)) pts)
  (define move-rows (make-move ar br 'down 'up))
  (define move-cols (make-move ac bc 'right 'left))

  (match* (ar ac br bc)
    [(r _ r _) (list (append move-cols '(push)))]
    [(_ c _ c) (list (append move-rows '(push)))]
    [(3 _ _ 1) (list (append move-rows move-cols '(push)))]
    [(_ 1 3 _) (list (append move-cols move-rows '(push)))]
    [(_ _ _ _) (list (append move-rows move-cols '(push)) (append move-cols move-rows '(push)))]))

(define (numpad-directions code)
  (~>> code (~a "A") string->list (map num-to-coord) (sliding _ 2) (map to-next-numeric)))

(define (to-next-direction pts)
  (match-define (list (Posn ar ac) (Posn br bc)) pts)
  (define move-rows (make-move ar br 'down 'up))
  (define move-cols (make-move ac bc 'right 'left))

  (match* (ar ac br bc)
    [(r _ r _) (list (append move-cols '(push)))]
    [(_ c _ c) (list (append move-rows '(push)))]
    [(0 _ 1 1) (list (append move-rows move-cols '(push)))]
    [(1 1 0 _) (list (append move-cols move-rows '(push)))]
    [(_ _ _ _) (list (append move-rows move-cols '(push)) (append move-cols move-rows '(push)))]))

(define (direction-directions directions)
  (~> directions (cons 'push _) (map dir-to-coord _) (sliding 2) (map to-next-direction _)))

(define/memoize (count-presses move remaining)
                #:hash hash
                (cond
                  [(zero? remaining) (apply min (map length move))]
                  [else
                   (for/min ([branch (in-list move)])
                            (for/sum ([step (in-list (direction-directions branch))])
                                     (count-presses step (sub1 remaining))))]))

(define (chain-robots n)
  (for*/sum ([code (in-list codes)] [steps (in-list (numpad-directions code))])
            (* (count-presses steps n) (~> code (string-replace "A" "") string->number))))

;; part 1
(chain-robots 2)

;; part 2
(chain-robots 25)

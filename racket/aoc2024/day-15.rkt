#lang racket

(require advent-of-code
         threading
         "utils/posn.rkt")

(struct Move (posn kind) #:transparent)

(define raw-input (fetch-aoc-input (find-session) 2024 15 #:cache #true))
(match-define (list raw-grid raw-instructions) (string-split raw-input "\n\n"))

(define grid
  (string->posn-grid
   raw-grid
   (match-λ [#\. 'nothing] [#\O 'box] [#\# 'wall] [#\[ 'left-box] [#\] 'right-box] [#\@ 'robot])))

(define instructions
  (~> raw-instructions
      string->list
      (filter-map (match-λ [#\v 'down] [#\^ 'up] [#\< 'left] [#\> 'right] [_ #f]) _)))

(define (go robot dir)
  (match-define (Posn x y) robot)
  (match dir
    ['up (Posn x (sub1 y))]
    ['down (Posn x (add1 y))]
    ['left (Posn (sub1 x) y)]
    ['right (Posn (add1 x) y)]))

(define (next-movement robot grid instructions)
  (cond
    [(empty? instructions) grid]
    [else
     (match-define (cons next remaining) instructions)
     (println next)
     (define moving-to (go robot next))
     (define things-to-move
       (match* ((hash-ref grid moving-to #f) next)
         [('nothing _) (list (Move robot 'robot))]
         [('box _) (check-horizontal-boxes robot grid next '())]
         [((or 'left-box 'right-box) (or 'left 'right)) (check-horizontal-boxes robot grid next '())]
         [((or 'left-box 'right-box) (or 'up 'down)) (check-vertical-boxes robot grid next '())]
         [('wall _) '()]))

     (move-things things-to-move grid next moving-to remaining)]))

(define (move-things things grid direction dest steps)
  (~> things
      (foldl (λ (b acc) (hash-set acc (Move-posn b) 'nothing)) grid _)
      (foldl (λ (b acc) (hash-set acc (go (Move-posn b) direction) (Move-kind b))) _ things)
      (next-movement dest _ steps)))

(define (check-horizontal-boxes posn grid direction acc)
  (define destination (go posn direction))
  (define moved (Move posn (hash-ref grid posn)))
  (match (hash-ref grid destination #f)
    ['wall '()]
    ['nothing
     (println (~a "Horizontal" (cons moved acc)))
     (cons moved acc)]
    [(or 'left-box 'right-box 'box)
     (check-horizontal-boxes destination grid direction (cons moved acc))]))

(define (check-vertical-boxes posn grid direction acc)
  (define destination (go posn direction))
  (match (hash-ref grid destination #f)
    ['wall #f]
    ['nothing
     (println (~a "Vertical" acc))
     acc]
    [(and (or 'left-box 'right-box) box)
     (~>> (if (equal? box 'left-box)
              (list destination (go destination 'right))
              (list destination (go destination 'left)))
          (andmap (λ (b)
                    (define type (hash-ref grid b))
                    (check-vertical-boxes b grid direction (cons (Move b type) acc)))))]))

(define robot-start
  (for/first ([(k v) (in-hash grid)]
              #:when (equal? v 'robot))
    k))

(for/fold ([sum 0])
          ([(k v) (in-hash (next-movement robot-start grid instructions))]
           #:when (member v '(box left-box)))
  (+ sum (Posn-x k) (* 100 (Posn-y k))))

;; in progress
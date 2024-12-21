#lang racket

(require advent-of-code
         "utils/posn.rkt")

(define grid
  (string->posn-grid (fetch-aoc-input (find-session) 2024 20 #:cache #true)
                     (match-λ [#\S 'start] [#\E 'end] [#\# 'wall] [#\. 'path])))

(define (enumerate-path grid)
  (define start
    (for/first ([(k v) (in-hash grid)]
                #:when (equal? v 'start))
      k))
  (define start-path (hash start 0))

  (define (do-enumerate [posn start] [path start-path] [i 0] [seen (set start)])
    (define next
      (for/first ([neighbor (in-list (neighbors-of posn in-cardinal-directions))]
                  #:unless (set-member? seen neighbor)
                  #:unless (equal? (hash-ref grid neighbor #f) 'wall))
        neighbor))
    (define new-path (hash-set path next i))
    (cond
      [(equal? (hash-ref grid next #f) 'end) new-path]
      [else (do-enumerate next new-path (add1 i) (set-add seen next))]))

  (do-enumerate))

(define (reachable-nodes origin reach)
  (for*/list ([dy (in-inclusive-range (- reach) reach)]
              #:do [(define vertical-span (- reach (abs dy)))]
              [dx (in-inclusive-range (- vertical-span) vertical-span)])
    (posn-add origin (Posn dx dy))))

(define/match (manhattan-distance _p1 _p2)
  [((Posn x1 y1) (Posn x2 y2)) (+ (abs (- x1 x2)) (abs (- y1 y2)))])

(define (search-for-shortcuts path reach)
  (for*/sum ([(a n) (in-dict path)] ;
             [b (in-list (reachable-nodes a reach))]
             #:when (hash-has-key? path b)
             #:do [(define m (hash-ref path b)) ;
                   (define dist (manhattan-distance a b))]
             #:when ((- m n dist) . >= . 100))
            1))

;; part 1
(define enumerated-path (enumerate-path grid))
(search-for-shortcuts enumerated-path 2)

;; part 2
(search-for-shortcuts enumerated-path 20)

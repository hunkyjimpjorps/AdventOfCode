#lang racket

(require advent-of-code
         threading
         algorithms)

(define data (fetch-aoc-input (find-session) 2022 14 #:cache #true))

(define (trace-line-between-points p1 p2)
  (match* (p1 p2)
    [((list x y1) (list x y2)) (map (λ (y) (cons x y)) (inclusive-range (min y1 y2) (max y1 y2)))]
    [((list x1 y) (list x2 y)) (map (λ (x) (cons x y)) (inclusive-range (min x1 x2) (max x1 x2)))]))

(define (find-points-in-structure str)
  (define endpoints
    (for/list ([coord-pair (in-list (string-split str " -> "))])
      (for/list ([coord (in-list (string-split coord-pair ","))])
        (string->number coord))))
  (~>> endpoints (adjacent-map trace-line-between-points) (apply append) (list->set)))

(define blocked-locations
  (~> data (string-split "\n") (map find-points-in-structure _) (apply set-union _)))

(define max-vertical-distance (~>> blocked-locations (set->list) (argmax cdr) cdr add1))

(define (open? pts p)
  (not (set-member? pts p)))

;; part 1
(define (trace-grain pts [pt (cons 500 0)] #:at-limit do-at-limit)
  (match-define (cons x y) pt)
  (cond
    [(>= y max-vertical-distance) (do-at-limit pts pt)]
    [(ormap (λ (d)
              (let ([p* (cons (+ x d) (add1 y))])
                (if (open? pts p*) (trace-grain pts p* #:at-limit do-at-limit) #f)))
            '(0 -1 1))]
    [else (set-add pts pt)]))

(for/fold ([pts blocked-locations] [grains 0] #:result grains) ([_ (in-naturals 1)])
  (define pts* (trace-grain pts #:at-limit (const 'break)))
  #:break (equal? pts* 'break)
  (values pts* (add1 grains)))

;; part 2
(for/fold ([pts blocked-locations] [grains 0] #:result grains) ([_ (in-naturals 1)])
  #:break (not (open? pts (cons 500 0)))
  (define pts* (trace-grain pts #:at-limit set-add))
  (values pts* (add1 grains)))

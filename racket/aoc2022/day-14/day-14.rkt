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
(define (trace-grain pts path #:at-limit do-at-limit)
  (match-define (list* (and p (cons x y)) _) path)
  (match-define (list dest-1 dest-2 dest-3) (map (λ (d) (cons (+ x d) (add1 y))) '(0 -1 1)))
  (cond
    [(>= y max-vertical-distance) (values (do-at-limit pts p) path)]
    [(open? pts dest-1) (trace-grain pts (cons dest-1 path) #:at-limit do-at-limit)]
    [(open? pts dest-2) (trace-grain pts (cons dest-2 path) #:at-limit do-at-limit)]
    [(open? pts dest-3) (trace-grain pts (cons dest-3 path) #:at-limit do-at-limit)]
    [else (values (set-add pts (car path)) path)]))

(time (for/fold ([pts blocked-locations] [path (list (cons 500 0))] [grains 0] #:result grains)
                ([_ (in-naturals 1)])
        (define-values (pts* path*) (trace-grain pts path #:at-limit (const 'break)))
        #:break (equal? pts* 'break)
        (values pts* (cdr path*) (add1 grains))))

;; part 2
(time (for/fold ([pts blocked-locations] [path (list (cons 500 0))] [grains 0] #:result grains)
                ([_ (in-naturals 1)])
        #:break (not (open? pts (cons 500 0)))
        (define-values (pts* path*) (trace-grain pts path #:at-limit set-add))
        (values pts* (cdr path*) (add1 grains))))

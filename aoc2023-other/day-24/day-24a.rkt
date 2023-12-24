#lang rosette

(require advent-of-code
         threading)

(struct hail (posn vel) #:transparent)
(struct posn (x y z) #:transparent)
(struct vel (x y z) #:transparent)

(define input (fetch-aoc-input (find-session) 2023 24 #:cache #true))

(define LOWER-BOUND 200000000000000)
(define UPPER-BOUND 400000000000000)

(define (parse-hail-record str)
  (match-define (list p v) (string-split str " @ "))
  (hail (~> p (string-split ",") (map (λ~> string-trim string->number) _) (apply posn _))
        (~> v (string-split ",") (map (λ~> string-trim string->number) _) (apply vel _))))

(define hail-paths
  (for/list ([hail (in-list (string-split input "\n"))])
    (parse-hail-record hail)))

;; part 1
(define (valid-intersection? h1 h2)
  (match-define (hail (posn x1 y1 _) (vel vx1 vy1 _)) h1)
  (match-define (hail (posn x2 y2 _) (vel vx2 vy2 _)) h2)
  (cond
    [(= (* vy1 vx2) (* vx1 vy2)) #f]
    [else
     (define t1 (/ (- (* vy2 (- x1 x2)) (* vx2 (- y1 y2))) (- (* vy1 vx2) (* vx1 vy2))))
     (define t2 (/ (- (* vy1 (- x2 x1)) (* vx1 (- y2 y1))) (- (* vy2 vx1) (* vx2 vy1))))

     (define x (+ x1 (* t1 vx1)))
     (define y (+ y1 (* t1 vy1)))

     (and (<= LOWER-BOUND x UPPER-BOUND) (<= LOWER-BOUND y UPPER-BOUND) (<= 0 t1) (<= 0 t2))]))

(for/sum ([(trial-paths) (in-combinations hail-paths 2)] ;
          #:when (apply valid-intersection? trial-paths))
         1)

;; part 2 - see day-24b.rkt

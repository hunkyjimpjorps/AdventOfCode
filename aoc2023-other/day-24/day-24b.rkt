#lang rosette

(require advent-of-code
         threading)

(struct hail (posn vel) #:transparent)
(struct posn (x y z) #:transparent)
(struct vel (x y z) #:transparent)

(define input (fetch-aoc-input (find-session) 2023 24 #:cache #true))

(define (->struct f str)
  (~> str (string-split ",") (map (λ~> string-trim string->number) _) (apply f _)))

(define (parse-hail-record str)
  (match-define (list p v) (string-split str " @ "))
  (hail (->struct p posn) (->struct v vel)))

(define hail-paths
  (for/list ([hail (in-list (string-split input "\n"))] ;
             [_ (in-range 3)])
    (parse-hail-record hail)))

;; part 1 - see day-24a.rkt
;; part 2

(define-symbolic px py pz vx vy vz integer?)

(define sol
  (solve ;
   (for ([path (in-list hail-paths)])
     (define-symbolic* t integer?)
     (assert (= (+ px (* vx t)) (+ (~> path hail-posn posn-x) (* (~> path hail-vel vel-x) t))))
     (assert (= (+ py (* vy t)) (+ (~> path hail-posn posn-y) (* (~> path hail-vel vel-y) t))))
     (assert (= (+ pz (* vz t)) (+ (~> path hail-posn posn-z) (* (~> path hail-vel vel-z) t)))))))

(evaluate (+ px py pz) sol)

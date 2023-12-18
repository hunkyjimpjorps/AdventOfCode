#lang racket

(require advent-of-code
         threading
         data/heap)

(struct state (p heat-lost previous history) #:transparent)
(struct posn (r c) #:transparent)

(define/match (add _p1 _p2)
  [((posn r1 c1) (posn r2 c2)) (posn (+ r1 r2) (+ c1 c2))])

(define deltas (list (posn 0 1) (posn 0 -1) (posn 1 0) (posn -1 0)))

(define input (fetch-aoc-input (find-session) 2023 17 #:cache #true))

(define grid
  (for*/hash ([(row r) (in-indexed (in-list (string-split input "\n")))]
              [(col c) (in-indexed (in-string row))])
    (values (posn r c) (~> col string string->number))))

(define goal-posn (~>> grid hash-keys (argmax (λ (p) (+ (posn-r p) (posn-c p))))))

(define (make-key s)
  (cons (state-p s) (same-dir s)))

(define (goal? n s)
  (and (equal? goal-posn (state-p s)) (>= (length (same-dir s)) n)))

(define (same-dir s)
  (define history (state-history s))
  (if (empty? history) '() (takef history (λ (n) (equal? n (car history))))))

(define (find-good-neighbors min-dist max-dist s)
  (match-define (state p hl prev hist) s)

  (define (eliminate-bad-neighbors delta)
    (define neighbor (add p delta))
    (cond
      [(or (equal? neighbor prev) (not (hash-has-key? grid neighbor))) #false]
      [else
       (define same (same-dir s))
       (define l (length same))
       (cond
         [(= max-dist l) (not (equal? delta (car same)))]
         [(= l 0) #true]
         [(< l min-dist) (equal? delta (car same))]
         [else #t])]))

  (define (make-state delta)
    (define neighbor (add p delta))
    (define new-loss (+ hl (hash-ref grid neighbor)))
    (state neighbor new-loss p (cons delta hist)))

  (~>> deltas (filter eliminate-bad-neighbors) (map make-state)))

(define (find-path neighbor-fn goal-fn)
  (define seen (mutable-set))
  (define queue (make-heap (λ (a b) (<= (state-heat-lost a) (state-heat-lost b)))))
  (heap-add! queue (state (posn 0 0) 0 'none '()))

  (let bfs ()
    (define s (heap-min queue))
    (heap-remove-min! queue)
    (define key (make-key s))
    (cond
      [(set-member? seen key) (bfs)]
      [else
       (set-add! seen key)
       (define neighbors (neighbor-fn s))
       (define final (findf goal-fn neighbors))
       (if final
           (state-heat-lost final)
           (begin
             (for ([n (in-list neighbors)])
               (heap-add! queue n))
             (bfs)))])))

;; part 1
(find-path (curry find-good-neighbors 0 3) (curry goal? 1))

;; part 2
(find-path (curry find-good-neighbors 4 10) (curry goal? 4))
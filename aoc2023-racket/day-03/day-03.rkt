#lang racket

(require advent-of-code
         threading)

(struct posn (x y) #:transparent)
(struct part (n posns) #:transparent)

(define (make-board port)
  (for*/hash ([(row y) (in-indexed (port->lines port))]
              [(col x) (in-indexed (string->list row))]
              #:unless (equal? col #\.))
    (define v
      (cond
        [(string->number (string col))]
        [(equal? col #\*) 'gear]
        [else 'other]))
    (values (posn x y) v)))

(define board (~> (open-aoc-input (find-session) 2023 3 #:cache #true) make-board))

(define (posn<? a b)
  (match-define (list (cons (posn a-x a-y) _) (cons (posn b-x b-y) _)) (list a b))
  (if (= a-y b-y) (< a-x b-x) (< a-y b-y)))

(define (find-cells f b)
  (~> (for/hash ([(k v) (in-hash b)] #:when (f v))
        (values k v))
      hash->list
      (sort posn<?)))

(define (group-into-parts cells [acc '()])
  (match* (cells acc)
    [('() acc)
     acc]
    [((list* (cons (and pt (posn x y)) n) cs)
      (list* (part n* (and pts (list* (posn x* y) rest-pts)))
             rest-acc))
     #:when (= (- x x*) 1)
     (group-into-parts cs (cons (part (+ n (* n* 10)) (cons pt pts)) rest-acc))]
    [((list* (cons pt n) cs) acc)
     (group-into-parts cs (cons (part n (list pt)) acc))]))

(define (neighbors p)
  (for*/list ([dx '(-1 0 1)]
              [dy '(-1 0 1)]
              #:unless (and (= dx 0) (= dy 0)))
    (posn (+ dx (posn-x p)) (+ dy (posn-y p)))))

(define to-neighbors (λ~>> part-posns (append-map neighbors) remove-duplicates))
(define (symbol-in-neighbors b pt acc)
  (~>> pt
       to-neighbors
       (ormap (λ (p) (let ([lookup (hash-ref b p #f)])
                       (or (equal? lookup 'gear) (equal? lookup 'other)))))
       ((λ (bool) (if bool (+ acc (part-n pt)) acc)))))

;; part 1
(define parts (~>> board (find-cells integer?) group-into-parts))
(foldl (curry symbol-in-neighbors board) 0 parts)

;; part 2
(define gears (~>> board (find-cells (curry equal? 'gear)) (map car)))
(define parts-with-neighbors (map (λ (pt) (struct-copy part pt [posns (to-neighbors pt)])) parts))

(define (find-parts-near-gear pts gear)
  (filter-map (λ (pt) (and (findf (curry equal? gear) (part-posns pt)) (part-n pt))) pts))

(~>> gears
     (filter-map (λ~>> (find-parts-near-gear parts-with-neighbors)
                       ((λ (ns) (if (= (length ns) 2) (* (first ns) (second ns)) #f)))))
     (apply +))

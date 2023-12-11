#lang racket

(require advent-of-code
         threading)

(struct posn (x y) #:transparent)

(define input
  (~> (fetch-aoc-input (find-session) 2023 11 #:cache #true)
      (string-split "\n")
      (map string->list _)))

(define (get-empty-ranks grid)
  (for/list ([(rank n) (in-indexed grid)] #:when (equal? '(#\.) (remove-duplicates rank)))
    n))

(define (count-prior-empty-ranks rank empty-ranks)
  (~> empty-ranks (takef (curryr < rank)) length))

(define empty-rows (get-empty-ranks input))
(define empty-columns (get-empty-ranks (apply map list input))) ;; transpose

(define (sum-of-star-distances in expand-by)
  (define stars
    (for*/list ([(row x) (in-indexed in)] [(col y) (in-indexed row)] #:when (equal? col #\#))
      (posn (+ x (* (sub1 expand-by) (count-prior-empty-ranks x empty-rows)))
            (+ y (* (sub1 expand-by) (count-prior-empty-ranks y empty-columns))))))
  (for/sum ([star-pair (in-combinations stars 2)])
           (match-define (list (posn x1 y1) (posn x2 y2)) star-pair)
           (+ (abs (- x1 x2)) (abs (- y1 y2)))))

;; part 1
(sum-of-star-distances input 2)

;; part 2
(sum-of-star-distances input 1000000)

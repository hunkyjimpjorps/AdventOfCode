#lang racket

(require advent-of-code
         threading
         "../../jj-aoc.rkt")

(define input
  (~> (fetch-aoc-input (find-session) 2023 14 #:cache #true)
      string-split
      (map string->list _)
      transpose))

(define (roll-boulders board)
  (for/list ([col (in-list board)])
    (~> col (chunks-by (curry equal? #\#)) (append-map (curryr sort char>?) _))))

(define (score board)
  (for*/sum ([col (in-list board)] [(row n) (in-indexed (reverse col))] #:when (equal? row #\O))
            (add1 n)))

;; part 1
(~> input roll-boulders score)

;; part 2
(define (rotate-board xss)
  (~> xss (map reverse _) transpose))

(define (full-cycle board)
  (foldl (λ (_ acc) (~> acc roll-boulders rotate-board)) board (range 4)))

(define (spin-to-win board)
  (define cache (make-hash))
  (define (do-spin board n)
    (match (hash-ref cache board 'not-found)
      ['not-found
       (hash-set! cache board n)
       (do-spin (full-cycle board) (sub1 n))]
      [seen
       (define to-end (modulo n (- seen n)))
       (score (foldl (λ (_ acc) (full-cycle acc)) board (range to-end)))]))
  (do-spin board 1000000000))

(~> input spin-to-win)

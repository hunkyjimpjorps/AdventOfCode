#lang racket

(require advent-of-code
         threading)

(define id-ranges
  (for/list ([rng (~> (fetch-aoc-input (find-session) 2025 2 #:cache #true)
                      (string-trim)
                      (string-split ","))])
    (~> rng (string-split "-") (map string->number _))))

(define (repeat n times)
  (define shift (expt 10 (add1 (order-of-magnitude n))))
  (define (do-repeat acc t)
    (cond
      [(= 1 t) acc]
      [else (do-repeat (+ n (* acc shift)) (sub1 t))]))
  (do-repeat n times))

(define (in-range? n range-def)
  (match-define (list lo hi) range-def)
  (<= lo n hi))

;; part 1

(for/sum ([n (in-inclusive-range 1 99999)] ;
          #:do [(define nn (repeat n 2))]
          #:when (ormap (λ (r) (in-range? nn r)) id-ranges))
         nn)

;; part 2
(define additional-nonsense
  (apply set-union
         (for/list ([len (in-inclusive-range 1 5)]
                    [times (in-list '(10 5 3 2 2))])
           (for*/set ([l (in-range (expt 10 (sub1 len)) (expt 10 len))]
                      [t (in-inclusive-range 2 times)])
             (repeat l t)))))

(for/sum ([n (in-set additional-nonsense)] #:when (ormap (λ (r) (in-range? n r)) id-ranges)) n)

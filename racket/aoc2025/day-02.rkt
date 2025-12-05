#lang racket

(require advent-of-code
         threading
         (prefix-in iset: data/integer-set))

(define id-ranges
  (for/fold ([acc (iset:make-range)])
            ([rng (~> (fetch-aoc-input (find-session) 2025 2 #:cache #true)
                      (string-trim)
                      (string-split ","))])
    (~>> rng (string-split _ "-") (map string->number) (apply iset:make-range) (iset:union acc))))

(define (repeat n times)
  (define shift (expt 10 (add1 (order-of-magnitude n))))
  (define (do-repeat acc t)
    (cond
      [(= 1 t) acc]
      [else (do-repeat (+ n (* acc shift)) (sub1 t))]))
  (do-repeat n times))

;; part 1
(for/sum ([n (in-inclusive-range 1 99999)] ;
          #:do [(define nn (repeat n 2))]
          #:when (iset:member? nn id-ranges))
         nn)

;; part 2
(define additional-nonsense
  (apply set-union
         (for/list ([len (in-inclusive-range 1 5)]
                    [times (in-list '(10 5 3 2 2))])
           (for*/set ([l (in-range (expt 10 (sub1 len)) (expt 10 len))]
                      [t (in-inclusive-range 2 times)])
             (repeat l t)))))

(for/sum ([n (in-set additional-nonsense)] #:when (iset:member? n id-ranges)) n)

#lang racket

(require advent-of-code
         threading
         data/applicative
         data/monad
         megaparsack
         megaparsack/text)

(struct claim (number start-x start-y size-x size-y) #:transparent)

(define claim/p
  (do (char/p #\#)
      [number <- integer/p]
      (string/p " @ ")
      [start-x <- integer/p]
      (char/p #\,)
      [start-y <- integer/p]
      (string/p ": ")
      [size-x <- integer/p]
      (char/p #\x)
      [size-y <- integer/p]
      (pure (claim number start-x start-y size-x size-y))))

(define (parse-claim str)
  (parse-result! (parse-string claim/p str)))

(define (make-claim ht cl)
  (for*/fold ([fabric ht])
             ([x (in-range (claim-start-x cl) (+ (claim-start-x cl) (claim-size-x cl)))]
              [y (in-range (claim-start-y cl) (+ (claim-start-y cl) (claim-size-y cl)))])
    (hash-update fabric (cons x y) add1 0)))

(define claims
  (~> (port->lines (open-aoc-input (find-session) 2018 3 #:cache #true)) (map parse-claim _)))

(define claimed-fabric
  (for/fold ([fabric (hash)]) ([cl (in-list claims)])
    (make-claim fabric cl)))

;; part 1
(for/sum ([claim-count (in-list (hash-values claimed-fabric))] #:when (< 1 claim-count)) 1)

;; part 2
(define (uncontested-claim? fabric cl)
  (for*/and ([x (in-range (claim-start-x cl) (+ (claim-start-x cl) (claim-size-x cl)))]
             [y (in-range (claim-start-y cl) (+ (claim-start-y cl) (claim-size-y cl)))])
    (= 1 (hash-ref fabric (cons x y)))))

(for/first ([cl (in-list claims)] #:when (uncontested-claim? claimed-fabric cl))
  (claim-number cl))

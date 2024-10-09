#lang racket

(require advent-of-code
         data/applicative
         data/either
         data/monad
         megaparsack
         megaparsack/text
         threading)

(struct card (n wins))

(define card/p
  (do (string/p "Card")
    (many/p space/p)
    [n <- integer/p]
    (string/p ":")
    (many/p space/p)
    [winners <- (many-until/p integer/p #:sep (many/p space/p) #:end (try/p (string/p " | ")))]
    (many/p space/p)
    [has <- (many+/p integer/p #:sep (many/p space/p))]
    (pure (card n (set-count (set-intersect (first winners) has))))))

(define raw-cards (~> (open-aoc-input (find-session) 2023 4 #:cache #true) port->lines))

;; part 1
(for/sum ([raw-card (in-list raw-cards)]
          #:do [(match-define (success (card _ wins)) (parse-string card/p raw-card))]
          #:unless (= wins 0))
  (expt 2 (sub1 wins)))

;; part 2
(for/fold ([counts (for/hash ([n (in-inclusive-range 1 (length raw-cards))])
                     (values n 1))]
           #:result (apply + (hash-values counts)))
          ([raw-card (in-list raw-cards)]
           #:do [(match-define (success (card n wins)) (parse-string card/p raw-card))])
  (define bonus-range (inclusive-range (+ n 1) (+ n wins)))
  (define won-cards (hash-ref counts n))
  (foldl (λ (n acc) (hash-update acc n (curry + won-cards))) counts bonus-range))

#lang racket

(require advent-of-code
         threading
         memo)

(struct hand (cards wager) #:transparent)

(define/match (card->int card)
  [((? char-numeric?)) (~> card string string->number)]
  [(#\A) 14]
  [(#\K) 13]
  [(#\Q) 12]
  [(#\J) 11]
  [(#\T) 10]
  [(#\*) 1])

(define (parse-hand str)
  (match-define (list card-str wager-str) (string-split str))
  (define cards (~> card-str string->list (map card->int _)))
  (define wager (~> wager-str string->number))
  (hand cards wager))

(define input (~> (open-aoc-input (find-session) 2023 7 #:cache #true) port->lines))

(define/memoize (identify-hand h)
                (define freqs (~> h hand-cards (sort <) (group-by identity _) (map length _)))
                (match freqs
                  [(list-no-order 5) 8]
                  [(list-no-order 1 4) 7]
                  [(list-no-order 2 3) 6]
                  [(list-no-order 1 1 3) 5]
                  [(list-no-order 1 2 2) 4]
                  [(list-no-order 1 1 1 2) 3]
                  [(list-no-order 1 1 1 1 1) 2]
                  [_ 1]))

(define (compare-first-card cs1 cs2)
  (if (= (first cs1) (first cs2))
      (compare-first-card (rest cs1) (rest cs2))
      (< (first cs1) (first cs2))))

(define (compare-hands with h1 h2)
  (define rank1 (with h1))
  (define rank2 (with h2))
  (if (= rank1 rank2) (compare-first-card (hand-cards h1) (hand-cards h2)) (< rank1 rank2)))

;; part 1

(define (compare-hands-no-wilds h1 h2)
  (compare-hands identify-hand h1 h2))

(define (total-score with in)
  (for/sum ([(h i) (in-indexed (~> in (map parse-hand _) (sort with)))]) (* (add1 i) (hand-wager h))))

(total-score compare-hands-no-wilds input)

;; part 2

(define/memoize (find-best-joker-substitution h)
                (for/fold ([best-hand (hand '() 0)]) ([wild (in-inclusive-range 2 14)])
                  (define trial-hand
                    (hand (map (λ (c) (if (= c 1) wild c)) (hand-cards h)) (hand-wager h)))
                  (if (> (identify-hand trial-hand) (identify-hand best-hand)) trial-hand best-hand)))

(define (compare-hands-with-wilds h1 h2)
  (compare-hands (λ~> find-best-joker-substitution identify-hand) h1 h2))

(total-score compare-hands-with-wilds (map (curryr string-replace "J" "*") input))

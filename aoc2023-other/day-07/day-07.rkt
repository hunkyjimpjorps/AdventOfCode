#lang racket

(require advent-of-code
         threading)

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

(define (identify-hand h)
  (define freqs (~> h hand-cards (sort <) (group-by identity _) (map length _)))
  (match freqs
    [(list-no-order 5) 8]
    [(list-no-order 1 4) 7]
    [(list-no-order 2 3) 6]
    [(list-no-order 1 1 3) 5]
    [(list-no-order 1 2 2) 4]
    [(list-no-order 1 1 1 2) 3]
    [(list-no-order 1 1 1 1 1) 2]))

(define (compare-first-card cs1 cs2)
  (if (= (first cs1) (first cs2))
      (compare-first-card (rest cs1) (rest cs2))
      (< (first cs1) (first cs2))))

(define (compare-hands h1 h2)
  (define rank1 (identify-hand h1))
  (define rank2 (identify-hand h2))
  (if (= rank1 rank2) (compare-first-card (hand-cards h1) (hand-cards h2)) (< rank1 rank2)))

;; part 1

(for/sum ([(h i) (in-indexed (~> input (map parse-hand _) (sort compare-hands)))])
         (* (add1 i) (hand-wager h)))

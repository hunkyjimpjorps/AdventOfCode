#lang racket

(require advent-of-code)

(struct roll (id red green blue))

(define all-games
  (for/list ([raw-game (in-list (port->lines (open-aoc-input (find-session) 2023 2)))]
             #:do [(define game (string-trim raw-game "Game "))
                   (match-define (list id trials) (string-split game ": "))])
    (for/list ([trial (in-list (string-split trials "; "))])
      (for/fold ([acc (roll (string->number id) 0 0 0)])
                ([color (in-list (string-split trial ", "))])
        (match (string-split color)
          [(list (app string->number n) "red") (struct-copy roll acc [red n])]
          [(list (app string->number n) "green") (struct-copy roll acc [green n])]
          [(list (app string->number n) "blue") (struct-copy roll acc [blue n])])))))

;; part 1
(for/sum ([game (in-list all-games)]
          #:when (andmap (λ (g) (and ((roll-red g) . <= . 12)
                                     ((roll-green g) . <= . 13)
                                     ((roll-blue g) . <= . 14)))
                         game))
  (roll-id (first game)))

;; part 2
(for/sum ([game (in-list all-games)])
  (define max-cubes
    (for/fold ([acc (roll #f 0 0 0)]) ([r (in-list game)])
      (roll #f
            (max (roll-red acc) (roll-red r))
            (max (roll-green acc) (roll-green r))
            (max (roll-blue acc) (roll-blue r)))))
  (* (roll-red max-cubes) (roll-green max-cubes) (roll-blue max-cubes)))

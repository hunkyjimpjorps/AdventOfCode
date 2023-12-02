#lang racket

(require advent-of-code)

(struct roll (red green blue))

(define all-games
  (for/list ([raw-game (in-list (port->lines (open-aoc-input (find-session) 2023 2)))]
             #:do [(define game (string-trim raw-game "Game "))
                   (match-define (list id trials) (string-split game ": "))])
    (for/list ([trial (in-list (string-split trials "; "))])
      (for/fold ([acc (roll 0 0 0)]) ([color (in-list (string-split trial ", "))])
        (match (string-split color)
          [(list (app string->number n) "red") (struct-copy roll acc [red n])]
          [(list (app string->number n) "green") (struct-copy roll acc [green n])]
          [(list (app string->number n) "blue") (struct-copy roll acc [blue n])])))))

;; part 1
(for/sum ([(game id) (in-indexed all-games)])
         (define id-or-nothing
           (for/and ([r (in-list game)])
             (if (and ((roll-red r) . <= . 12) ((roll-green r) . <= . 13) ((roll-blue r) . <= . 14))
                 (add1 id)
                 #f)))
         (if id-or-nothing id-or-nothing 0))

;; part 2
(for/sum ([game (in-list all-games)])
         (define max-cubes
           (for/fold ([acc (roll 0 0 0)]) ([r (in-list game)])
             (roll (max (roll-red acc) (roll-red r))
                   (max (roll-green acc) (roll-green r))
                   (max (roll-blue acc) (roll-blue r)))))
         (* (roll-red max-cubes) (roll-green max-cubes) (roll-blue max-cubes)))

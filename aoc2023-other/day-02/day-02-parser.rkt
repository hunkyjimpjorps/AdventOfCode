#lang racket

(require racket/hash
         advent-of-code
         data/applicative
         data/either
         data/monad
         megaparsack
         megaparsack/text
         threading)

(struct game (id r g b))

(define cube/p
  (do [n <- integer/p]
      space/p
      [c <- (or/p (string/p "red") (string/p "blue") (string/p "green"))]
      (pure (cons c n))))

(define draw/p
  (do [xs <- (many/p cube/p #:min 1 #:max 3 #:sep (string/p ", "))] (pure (apply hash (flatten xs)))))

(define all-draws/p
  (do (string/p "Game ")
      [id <- integer/p]
      (string/p ": ")
      [all-draws <- (many/p draw/p #:min 1 #:sep (string/p "; "))]
      (define maxima (max-cubes all-draws))
      (pure (game id (hash-ref maxima "red") (hash-ref maxima "green") (hash-ref maxima "blue")))))

(define (max-cubes h)
  (foldl (curry hash-union #:combine max) (hash "red" 0 "green" 0 "blue" 0) h))

(define game-maxima
  (~>> (open-aoc-input (find-session) 2023 2)
       port->lines
       (map (λ~>> (parse-string all-draws/p) from-either))))

;; part 1
(for/sum ([m (in-list game-maxima)] #:unless
                                    (or (> (game-r m) 12) (> (game-g m) 13) (> (game-b m) 14)))
         (game-id m))

;; part 2
(for/sum ([m (in-list game-maxima)]) (* (game-r m) (game-g m) (game-b m)))

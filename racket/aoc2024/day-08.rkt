#lang racket

(require advent-of-code
         threading)

(struct Posn (x y) #:transparent)

(define (dist a b)
  (Posn (- (Posn-x b) (Posn-x a)) (- (Posn-y b) (Posn-y a))))

(define (go a delta)
  (Posn (+ (Posn-x a) (Posn-x delta)) (+ (Posn-y a) (Posn-y delta))))

(define (jump a b)
  (go a (dist b a)))

(define input (fetch-aoc-input (find-session) 2024 8 #:cache #true))

(define GRID
  (for*/hash ([(row y) (in-indexed (string-split input))]
              [(col x) (in-indexed row)])
    (values (Posn x y)
            (match col
              [#\. 'empty]
              [ch ch]))))

(define antenna-locations
  (for/fold ([acc (hash)])
            ([(posn antenna) (in-hash GRID)]
             #:unless (equal? antenna 'empty))
    (hash-update acc antenna (curry cons posn) list)))

(define (find-simple-antinodes posns)
  (~> (for*/set ([pair (in-combinations posns 2)]
                 #:do [(match-define (list a b) pair)]
                 [antinode (list (jump a b) (jump b a))]
                 #:when (hash-has-key? GRID antinode))
        antinode)))

;; part 1
(define (tally-antinodes with)
  (~>> (for*/set ([(_antenna posns) (in-hash antenna-locations)]
                  [antinode (in-set (with posns))])
         antinode)
       set-count))

(tally-antinodes find-simple-antinodes)

;; part 2
(define (find-all-antinodes posns)
  (~> (for*/set ([pair (in-combinations posns 2)]
                 #:do [(match-define (list a b) pair)]
                 [antinode (flatten (list (next-antinode b (dist a b))
                                          (next-antinode a (dist b a))))])
        antinode)))

(define (next-antinode posn delta [acc (list)])
  (if (dict-has-key? GRID posn)
      (next-antinode (go posn delta) delta (cons posn acc))
      acc))

(tally-antinodes find-all-antinodes)

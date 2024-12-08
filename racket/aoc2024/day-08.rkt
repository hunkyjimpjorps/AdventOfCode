#lang racket

(require advent-of-code
         threading)

(struct Posn (x y) #:transparent)

(define (dist a b)
  (Posn (- (Posn-x b) (Posn-x a)) (- (Posn-y b) (Posn-y a))))

(define (go a delta)
  (Posn (+ (Posn-x a) (Posn-x delta)) (+ (Posn-y a) (Posn-y delta))))

(define input (fetch-aoc-input (find-session) 2024 8 #:cache #true))

(define GRID
  (for*/hash ([(row x) (in-indexed (string-split input))]
              [(col y) (in-indexed row)])
    (values (Posn y x)
            (match col
              [#\. 'empty]
              [ch ch]))))

(define antenna-locations
  (for/fold ([acc (hash)])
            ([(posn antenna) (in-hash GRID)]
             #:unless (equal? antenna 'empty))
    (hash-update acc antenna (curry cons posn) list)))

(define (find-simple-antinodes posns)
  (~> (for/list ([pair (in-combinations posns 2)])
        (~>> pair
             (match _
               [(list a b) (list (go b (dist a b)) (go a (dist b a)))])
             (filter (curry hash-has-key? GRID))))
      flatten
      list->set))

;; part 1
(define (tally-antinodes with)
  (~>> antenna-locations ;
       hash-values
       (map with)
       (apply set-union)
       set-count))

(tally-antinodes find-simple-antinodes)

;; part 2
(define (find-all-antinodes posns)
  (~> (for/list ([pair (in-combinations posns 2)])
        (~>> pair
             (match _
               [(list a b) (list (next-antinode b (dist a b)) (next-antinode a (dist b a)))])
             flatten
             (filter (curry hash-has-key? GRID))))
      flatten
      list->set))

(define (next-antinode posn delta [acc (list)])
  (if (dict-has-key? GRID posn)
      (next-antinode (go posn delta) delta (cons posn acc))
      acc))

(tally-antinodes find-all-antinodes)

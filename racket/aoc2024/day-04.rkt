#lang racket

(require advent-of-code)

(struct pt (r c) #:transparent)
(define (next-row p)
  (pt (add1 (pt-r p)) 0))
(define (next-col p)
  (pt (pt-r p) (add1 (pt-c p))))
(define (go p d)
  (pt (+ (pt-r p) (pt-r d)) (+ (pt-c p) (pt-c d))))
(define DIRECTIONS
  (for*/list ([dr (in-list '(-1 0 1))]
              [dc (in-list '(-1 0 1))]
              #:unless (= dr dc 0))
    (pt dr dc)))

(define GRID
  (for*/hash ([(row r) (in-indexed (in-lines (open-aoc-input (find-session) 2024 4 #:cache #true)))]
              [(col c) (in-indexed (in-string row))])
    (values (pt r c) col)))
(define MAX 140)

;; part 1
(define (count-xmases [current (pt 0 0)] [acc 0])
  (cond
    [(= (pt-r current) MAX) acc]
    [(= (pt-c current) MAX) (count-xmases (next-row current) acc)]
    [(equal? (hash-ref GRID current #f) #\X)
     (define found (for/sum ([dir (in-list DIRECTIONS)]) (scan-for-word "MAS" (go current dir) dir)))
     (count-xmases (next-col current) (+ acc found))]
    [else (count-xmases (next-col current) acc)]))

(define (scan-for-word str current dir)
  (cond
    [(and (= (string-length str) 1) (equal? (string-ref str 0) (hash-ref GRID current #f))) 1]
    [(equal? (string-ref str 0) (hash-ref GRID current #f))
     (scan-for-word (substring str 1) (go current dir) dir)]
    [else 0]))

(count-xmases)

;; part 2
(define (count-x-mases [current (pt 0 0)] [acc 0])
  (cond
    [(= (pt-r current) MAX) acc]
    [(= (pt-c current) MAX) (count-x-mases (next-row current) acc)]
    [(equal? (hash-ref GRID current #f) #\A)
     (define found (live-mas current))
     (count-x-mases (next-col current) (+ acc found))]
    [else (count-x-mases (next-col current) acc)]))

(define (live-mas current)
  (define pattern
    (for/list ([dir (in-list (list (pt -1 -1) (pt 1 1) (pt -1 1) (pt 1 -1)))])
      (hash-ref GRID (go current dir) #\.)))
  (match (apply string pattern)
    [(or "MSMS" "MSSM" "SMSM" "SMMS") 1]
    [_ 0]))

(count-x-mases)

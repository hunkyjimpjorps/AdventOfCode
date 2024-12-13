#lang racket

(require advent-of-code
         "utils/posn.rkt")

(define GRID (string->posn-grid (fetch-aoc-input (find-session) 2024 4 #:cache #true)))
(define MAX 140)

;; part 1
(define (count-xmases [current (Posn 0 0)] [acc 0])
  (println current)
  (cond
    [(= (Posn-x current) MAX) acc]
    [(= (Posn-y current) MAX) (count-xmases (next-row current) acc)]
    [(equal? (hash-ref GRID current #f) #\X)
     (define found
       (for/sum ([dir (in-list in-all-directions)]) (scan-for-word "MAS" (posn-add current dir) dir)))
     (count-xmases (next-col current) (+ acc found))]
    [else (count-xmases (next-col current) acc)]))

(define (scan-for-word str current dir)
  (cond
    [(and (= (string-length str) 1) (equal? (string-ref str 0) (hash-ref GRID current #f))) 1]
    [(equal? (string-ref str 0) (hash-ref GRID current #f))
     (scan-for-word (substring str 1) (posn-add current dir) dir)]
    [else 0]))

(count-xmases)

;; part 2
(define (count-x-mases [current (Posn 0 0)] [acc 0])
  (cond
    [(= (Posn-x current) MAX) acc]
    [(= (Posn-y current) MAX) (count-x-mases (next-row current) acc)]
    [(equal? (hash-ref GRID current #f) #\A)
     (define found (live-mas current))
     (count-x-mases (next-col current) (+ acc found))]
    [else (count-x-mases (next-col current) acc)]))

(define (live-mas current)
  (define pattern
    (for/list ([dir (in-list in-diagonal-directions)])
      (hash-ref GRID (posn-add current dir) #\.)))
  (match (apply string pattern)
    [(or "MSMS" "MSSM" "SMSM" "SMMS") 1]
    [_ 0]))

(count-x-mases)

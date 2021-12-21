#lang racket
(require threading
         memoize)

;; not going to bother importing the data since it's just two lines of text
(define player-1-start 4)
(define player-2-start 6)

(define track (sequence->stream (in-cycle (inclusive-range 1 10))))
(define current-turn (in-cycle (list 'player-1 'player-2)))
(define die-rolls (sequence->stream (in-cycle (inclusive-range 1 100))))

;; part 1
(~> (for/fold ([player-1-score 0]
               [player-1-track (stream-tail track (sub1 player-1-start))]
               [player-2-score 0]
               [player-2-track (stream-tail track (sub1 player-2-start))]
               [dice die-rolls]
               [last-turn 0]
               #:result (list (min player-1-score player-2-score) (* 3 last-turn)))
              ([turn-count (in-naturals 1)]
               [turn current-turn]
               #:break (or (player-1-score . >= . 1000)
                           (player-2-score . >= . 1000)))
      (define rolls (apply + (stream->list (stream-take dice 3))))
      (cond
        [(equal? turn 'player-1)
         (values (+ player-1-score
                    (stream-first (stream-tail player-1-track rolls)))
                 (stream-tail player-1-track rolls)
                 player-2-score
                 player-2-track
                 (stream-tail dice 3)
                 turn-count)]
        [(equal? turn 'player-2)
         (values player-1-score
                 player-1-track
                 (+ player-2-score
                    (stream-first (stream-tail player-2-track rolls)))
                 (stream-tail player-2-track rolls)
                 (stream-tail dice 3)
                 turn-count)]))
  (apply * _))

;; part 2
(define d3 (list 1 2 3))
(define roll-space (~>> (cartesian-product d3 d3 d3)
                        (map (λ~>> (apply +)))))

(define/memo (next-turns p1-score p2-score p1-start p2-start)
  (cond
    [(p1-score . >= . 21) '(1 0)]
    [(p2-score . >= . 21) '(0 1)]
    [else
     (for/fold ([p-wins '(0 0)])
               ([roll (in-list roll-space)])
       (define move-to (~> p1-start
                         (+ roll)
                         sub1
                         (modulo 10)
                         add1))
       (match-define (list p1-wins p2-wins) p-wins)
       (match-define (list p2-possible-win p1-possible-win)
         (next-turns p2-score
                     (+ p1-score move-to)
                     p2-start
                     move-to))
       (list (+ p1-wins p1-possible-win)
             (+ p2-wins p2-possible-win)))]))

(~>> (next-turns 0 0 player-1-start player-2-start) (apply max))
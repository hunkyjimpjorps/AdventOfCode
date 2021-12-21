#lang racket
(require "../../jj-aoc.rkt"
         threading)

;; not going to bother importing the data since it's just two lines of text
(define player-1-start 4)
(define player-2-start 6)

(define track (sequence->stream (in-cycle (inclusive-range 1 10))))
(define current-turn (in-cycle (list 'player-1 'player-2)))
(define die-rolls (sequence->stream (in-cycle (inclusive-range 1 100))))

;; part 1
(~> (for/fold ([player-1-score 0]
               [player-1-space (stream-tail track (sub1 player-1-start))]
               [player-2-score 0]
               [player-2-space (stream-tail track (sub1 player-2-start))]
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
                    (stream-first (stream-tail player-1-space rolls)))
                 (stream-tail player-1-space rolls)
                 player-2-score
                 player-2-space
                 (stream-tail dice 3)
                 turn-count)]
        [(equal? turn 'player-2)
         (values player-1-score
                 player-1-space
                 (+ player-2-score
                    (stream-first (stream-tail player-2-space rolls)))
                 (stream-tail player-2-space rolls)
                 (stream-tail dice 3)
                 turn-count)]))
  (apply * _))
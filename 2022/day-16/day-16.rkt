#lang racket

(require advent-of-code
         fancy-app
         graph
         threading)

(define (process-line str)
  (match str
    [(regexp #px"Valve (\\w\\w) has flow rate=(\\d+); tunnels? leads? to valves? (.+)"
             (list _ name (app string->number rate) (app (string-split _ ", ") valves)))
     (list name rate valves)]))

(define cave-data
  (~> (fetch-aoc-input (find-session) 2022 16 #:cache #true)
      (string-split "\n")
      (map process-line _)))

(define cave-map
  (for*/lists (tunnels #:result (directed-graph tunnels))
              ([valve (in-list cave-data)] #:do [(match-define (list name _ valves) valve)]
                                           [destination (in-list valves)])
              (list name destination)))

(define valve-flows
  (for/hash ([valve (in-list cave-data)]
             #:do [(match-define (list name flow _) valve)]
             #:when (> flow 0))
    (values name flow)))

(define shortest-path-lengths (johnson cave-map))

(define (reachable-destinations start dests minutes-left)
  (for/list ([(dest _) (in-hash dests)]
             #:do [(define travel-time
                     (hash-ref shortest-path-lengths (list start dest) minutes-left))]
             #:when (<= 1 travel-time minutes-left))
    (cons dest travel-time)))

;; part 1
(define (find-best-single-route start
                                [minutes-left 30]
                                [current-pressure 0]
                                [available-valves valve-flows])
  (cond
    [(>= minutes-left 1)
     (for/fold ([running-pressure current-pressure]
                [remaining-valves available-valves]
                #:result (cons running-pressure remaining-valves))
               ([candidate (reachable-destinations start available-valves minutes-left)])
       (match-define (cons dest travel-time) candidate)
       (define minutes-left* (- minutes-left (add1 travel-time)))
       (match-define (cons candidate-pressure remaining-valves*)
         (find-best-single-route dest
                                 minutes-left*
                                 (+ current-pressure (* (hash-ref valve-flows dest) minutes-left*))
                                 (hash-remove available-valves dest)))
       (if (> candidate-pressure running-pressure)
           (values candidate-pressure remaining-valves*)
           (values running-pressure remaining-valves*)))]
    [else (cons current-pressure available-valves)]))

(car (find-best-single-route "AA"))
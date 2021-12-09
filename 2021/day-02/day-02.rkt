#lang racket
(require advent-of-code
         threading
         algorithms)

(define motion-data
  (~> (open-aoc-input (find-session) 2021 2 #:cache (string->path "./cache"))
      (port->list read _)
      (chunks-of _ 2)))

;; part 1
(for/fold ([depth 0]
           [position 0]
           #:result (* depth position))
          ([motion (in-list motion-data)])
  (match motion
    [(list 'forward x) (values depth
                               (+ position x))]
    [(list 'up x) (values (- depth x)
                          position)]
    [(list 'down x) (values (+ depth x)
                            position)]))

;; part 2
(for/fold ([aim 0]
           [depth 0]
           [position 0]
           #:result (* depth position))
          ([motion (in-list motion-data)])
  (match motion
    [(list 'forward x) (values aim
                               (+ depth (* aim x))
                               (+ position x))]
    [(list 'up x) (values (- aim x)
                          depth
                          position)]
    [(list 'down x) (values (+ aim x)
                            depth
                            position)]))
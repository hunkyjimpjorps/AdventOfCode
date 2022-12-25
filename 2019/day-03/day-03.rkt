#lang racket

(require advent-of-code
         threading
         fancy-app
         racket/hash)

(define/match (instruction-parse _str)
  [((regexp #px"(.)(.+)" (list _ (app string->symbol dir) (app string->number amt)))) (cons dir amt)])

(define (wire-parse str)
  (~> str (string-split ",") (map instruction-parse _)))

(define wires
  (~>> (fetch-aoc-input (find-session) 2019 3 #:cache #true) string-split (map wire-parse)))

(define (manhattan-distance-from-origin p)
  (+ (abs (car p)) (abs (cdr p))))

(define (trace-wire-path wire)
  (for/fold ([path (hash)] [x 0] [y 0] [len 0] #:result path) ([inst (in-list wire)])
    (define-values (x* y*)
      (match inst
        [(cons 'U dy) (values x (+ y dy))]
        [(cons 'D dy) (values x (- y dy))]
        [(cons 'R dx) (values (+ x dx) y)]
        [(cons 'L dx) (values (- x dx) y)]))
    (define next-segment
      (for*/list ([new-x (inclusive-range x x* (if (< x x*) 1 -1))]
                  [new-y (inclusive-range y y* (if (< y y*) 1 -1))])
        (cons new-x new-y)))
    (define numbered-segments
      (for/hash ([segment (in-list next-segment)] [new-len (in-naturals len)])
        (values segment new-len)))
    (values (hash-union path numbered-segments #:combine (λ (v0 _) v0)) x* y* (+ len (cdr inst)))))

;; part 1
(define wire-paths (map trace-wire-path wires))

(define intersections
  (~>> wire-paths
       (map (λ~> hash-keys list->set))
       (apply set-intersect)
       (set-remove _ '(0 . 0))
       set->list))

(~>> intersections (map manhattan-distance-from-origin) (apply min))

;; part 2
(~>> (for/list ([intersection (in-list intersections)])
       (~>> wire-paths (map (hash-ref _ intersection)) (apply +)))
     (apply min))

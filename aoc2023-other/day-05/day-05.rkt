#lang racket

(require advent-of-code
         algorithms
         threading)

(struct map-range (start end offset) #:transparent)
(struct seed-range (start end) #:transparent)

(define input (fetch-aoc-input (find-session) 2023 5 #:cache #true))

(match-define (list* raw-seeds raw-mappings) (string-split input "\n\n"))

(define seeds-naive (~> raw-seeds (string-split " ") rest (map string->number _)))
(define mappers
  (for/list ([raw-mapping (in-list raw-mappings)])
    (for/lists (map-ranges #:result (sort map-ranges < #:key map-range-start))
               ([raw-map-range (in-list (rest (string-split raw-mapping "\n")))]
                #:do [(match-define (list dest source width)
                        (~> raw-map-range (string-split _ " ") (map string->number _)))])
               (map-range source (+ source width -1) (- dest source)))))

;; part 1
(define (in-map-range? n mr)
  (<= (map-range-start mr) n (map-range-end mr)))

(define (transform-value mapper n)
  (match mapper
    ['() n]
    [(list* mr _)
     #:when (in-map-range? n mr)
     (+ n (map-range-offset mr))]
    [(list* _ rest-mapper) (transform-value rest-mapper n)]))

(for/lists (transforms #:result (apply min transforms))
           ([seed (in-list seeds-naive)])
           (foldl transform-value seed mappers))

;; part 2
(define (remap-range r mapper [acc '()])
  (match-define (seed-range r-start r-end) r)
  (match mapper
    ['() (cons r acc)]
    [(list* (map-range m-start _ _) _)
     #:when (< r-end m-start)
     (cons r acc)]
    [(list* (map-range _ m-end _) ms)
     #:when (< m-end r-start)
     (remap-range r ms acc)]
    [(list* (map-range m-start m-end offset) _)
     #:when (and (<= m-start r-start) (<= r-end m-end))
     (cons (seed-range (+ r-start offset) (+ r-end offset)) acc)]
    [(list* (map-range m-start m-end offset) ms)
     #:when (and (< m-start r-start) (<= m-end r-end))
     (remap-range (seed-range (add1 m-end) r-end)
                  ms
                  (cons (seed-range (+ r-start offset) (+ m-end offset)) acc))]
    [(list* (map-range m-start m-end offset) ms)
     (remap-range (seed-range (add1 m-end) r-end)
                  ms
                  (cons (seed-range (+ m-start offset) (+ m-end offset))
                        (cons (seed-range (add1 m-end) r-end) acc)))]))

(define (remap-ranges rs mappers)
  (cond
    [(empty? mappers) rs]
    [else
     (~>> rs (append-map (curryr remap-range (first mappers))) (remap-ranges _ (rest mappers)))]))

(~> seeds-naive
    (chunks-of 2)
    (map (λ (xs)
           (match-define (list start width) xs)
           (~> (list (seed-range start (+ start width -1)))
               (remap-ranges mappers)
               (argmin seed-range-start _)))
         _)
    (argmin seed-range-start _)
    seed-range-start)

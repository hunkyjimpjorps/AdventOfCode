#lang racket
(require threading
         awesome-list
         "../../jj-aoc.rkt")

(struct trial-data (signal output) #:transparent)

(define (string->sets s)
  (~> s
      string-split
      (map (λ~> string->list
                list->set) _)))

(define data
  (for/list ([l (in-lines (open-day 8))]
             #:unless (equal? l ""))
    (~> l
        (string-split _ " | ")
        (map string->sets _)
        (apply trial-data _))))

;; part 1
(for*/sum ([trial (in-list data)]
           [output (in-list (trial-data-output trial))]
           #:when (ormap (λ~> (= (set-count output))) '(2 3 4 7)))
  1)

;; part 2
(define (matching-pattern len trial)
  (define solution-set
    (for*/list ([signal (in-list (trial-data-signal trial))]
                #:when (= (set-count signal) len))
      signal))
  (match solution-set
    [(list s) s]
    [s (apply set-intersect s)]))

(define (determine-arrangement t)
  (let*
      ([pattern-1 (matching-pattern 2 t)]
       [pattern-4 (matching-pattern 4 t)]
       [pattern-7 (matching-pattern 3 t)]
       [pattern-8 (matching-pattern 7 t)]
       [pattern-shared-235 (matching-pattern 5 t)]
       [pattern-3 (set-union pattern-1
                             pattern-shared-235)]
       [pattern-9 (set-union pattern-4
                             pattern-shared-235)]
       [pattern-shared-069 (matching-pattern 6 t)]
       [pattern-just-f (set-subtract pattern-shared-069 pattern-shared-235)]
       [pattern-just-e (set-subtract pattern-8
                                     (set-union pattern-4
                                                pattern-shared-235
                                                pattern-shared-069))]
       [pattern-2 (set-union (set-subtract pattern-3 pattern-just-f)
                             pattern-just-e)]
       [pattern-just-c (set-subtract (set-intersect pattern-4 pattern-7)
                                     pattern-just-f)]
       [pattern-6 (set-subtract pattern-8 pattern-just-c)]
       [pattern-5 (set-subtract pattern-6 pattern-just-e)]
       [pattern-0 (set-union (set-subtract pattern-8
                                           pattern-shared-235)
                             pattern-shared-069)]
       )
    (~> (list pattern-0
              pattern-1
              pattern-2
              pattern-3
              pattern-4
              pattern-5
              pattern-6
              pattern-7
              pattern-8
              pattern-9)
        enumerate
        make-hash)))

(for/sum ([trial (in-list data)])
  (~>> trial
       trial-data-output
       (map (λ~>> (hash-ref (determine-arrangement trial))))
       (apply ~a)
       string->number))

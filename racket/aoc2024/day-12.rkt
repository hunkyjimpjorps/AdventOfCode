#lang racket

(require advent-of-code
         threading
         "utils/posn.rkt")

(define GRID (string->posn-grid (fetch-aoc-input (find-session) 2024 12 #:cache #true)))

(define (find-contiguous-regions [grid GRID] [acc '()])
  (match (hash-iterate-first grid)
    [#f acc]
    [n
     (define-values (posn plant) (hash-iterate-key+value grid n))
     (define region (flood-fill grid (list posn) (set) plant))
     (define trimmed-grid (sequence-fold (λ (acc k) (hash-remove acc k)) grid region))
     (find-contiguous-regions trimmed-grid (cons region acc))]))

(define (flood-fill grid stack seen plant)
  (match stack
    ['() seen]
    [(list* next rest)
     #:when (or (set-member? seen next) (not (equal? plant (hash-ref grid next #f))))
     (flood-fill grid rest seen plant)]
    [(list* next rest)
     (flood-fill grid
                 (append rest (neighbors-of next in-cardinal-directions))
                 (set-add seen next)
                 plant)]))

(define area set-count)
(define (perimeter region)
  (for/sum ([posn (in-set region)])
           (count (λ~>> (set-member? region) not) (neighbors-of posn in-cardinal-directions))))

(define (sides region)
  (for*/sum ([posn (in-set region)] ;
             #:do [(match-define (list u ur r dr d dl l ul)
                     (map (λ~>> (set-member? region)) (neighbors-of posn in-all-directions)))
                   (define vertices
                     (list (and (not u) (not l))
                           (and (not u) (not r))
                           (and (not d) (not l))
                           (and (not d) (not r))
                           (and u l (not ul))
                           (and u r (not ur))
                           (and d l (not dl))
                           (and d r (not dr))))]
             [vertex (in-list vertices)]
             #:when vertex)
            1))

(define REGIONS (find-contiguous-regions))
(define (score with)
  (for/sum ([region (in-list REGIONS)]) (* (area region) (with region))))

;; part 1
(score perimeter)

;; part 2
(score sides)

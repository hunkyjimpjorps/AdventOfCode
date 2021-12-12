#lang racket
(require "../../jj-aoc.rkt"
         threading)

(define coords
  (~>> (for/list ([r (in-range 10)])
         (for/list ([c (in-range 10)])
           (cons r c)))
       (apply append)))

(define octopus-data
  (~>> (for/list ([l (in-lines (open-day 11 2021))]
                  #:unless (equal? l ""))
         (~>> l
              string->list
              (map (λ~>> ~a string->number))))
       (apply append)
       (map cons coords)
       make-hash))

(define total-length (hash-count octopus-data))
(define row-length (sqrt total-length))

(define (adjacent-to coord)
  (match-define (cons r c) coord)
  (for*/list ([row (in-list '(-1 0 1))]
              [col (in-list '(-1 0 1))]
              #:unless (= 0 row col))
    (cons (+ r row) (+ c col))))

(define (simulate-octopi-step data)
  (define flashed-this-step (mutable-set))
  
  (let look-for-more-flashes
    ([octopi (for/hash ([(k v) data])
               (values k (add1 v)))]
     [flashes-so-far 0])
    (define-values (next-octopus-update
                    flashes-this-update)
      (for*/fold ([octopi octopi] [flashes 0])
                 ([(p x) (in-hash octopi)]
                  #:when (> x 9)
                  #:unless (set-member? flashed-this-step p))
        (set-add! flashed-this-step p)
        (define flashed-octopi
          (for*/fold ([o (hash-set octopi p 0)])
                     ([adj (in-list (adjacent-to p))]
                      #:when (hash-has-key? o adj)
                      #:unless (set-member? flashed-this-step adj))
            (hash-update o adj add1)))
        (values flashed-octopi
                (add1 flashes))))
    (if (> flashes-this-update 0)
        (look-for-more-flashes next-octopus-update
                               (+ flashes-so-far
                                  flashes-this-update))
        (values next-octopus-update
                flashes-so-far))))

;; part 1
(for/fold ([octopi octopus-data]
           [total-flashes 0] #:result total-flashes)
          ([step (in-range 100)])
  (define-values [next-state
                  flashes-from-this-state]
    (simulate-octopi-step octopi))
  (values next-state
          (+ total-flashes flashes-from-this-state)))

;; part 2
(for/fold ([octopi octopus-data]
           [synchro-step #f] #:result synchro-step)
          ([step (in-naturals 1)])
  (define-values [next-state
                  flashes-from-this-state]
    (simulate-octopi-step octopi))
  #:final (= flashes-from-this-state 100)
  (values next-state
          step))

#lang racket
(require advent-of-code
         threading)

(define data
  (~> (open-aoc-input (find-session) 2021 3 #:cache (string->path "./cache"))
      port->lines
      (map string->list _)))

;; part 1
(define most-common-bits
  (for*/list ([row (in-list (apply map list data))] [len (in-value (length data))])
    (if (> (count (λ (c) (char=? #\1 c)) row) (/ len 2)) #\1 #\0)))
(define (bit-list->number lst)
  (~> lst (apply string _) (string->number _ 2)))

(define gamma (bit-list->number most-common-bits))
(define epsilon (~> most-common-bits (map (λ (c) (if (char=? c #\1) #\0 #\1)) _) bit-list->number))

(* gamma epsilon)

;; part 2
(define (rating-search data comparison)
  (for/fold ([candidates data] #:result (bit-list->number (first candidates)))
            ([bit (in-list most-common-bits)] [bit-index (in-range 0 (length most-common-bits))])
    #:break (= 1 (length candidates))
    (define keep-bit
      (~> candidates
          (apply map list _)
          (list-ref _ bit-index)
          (count (λ (c) (char=? #\1 c)) _)
          (comparison _ (/ (length candidates) 2))
          (if _ #\1 #\0)))
    (filter (λ (row) (char=? keep-bit (list-ref row bit-index))) candidates)))

(define oxygen-rating (rating-search data >=))
(define scrubber-rating (rating-search data <))

(* oxygen-rating scrubber-rating)

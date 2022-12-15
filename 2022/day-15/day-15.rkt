#lang racket

(require advent-of-code
         threading
         fancy-app
         algorithms
         (prefix-in iset- data/integer-set))

(struct beacon-record (sensor beacon))
(struct posn (x y))

(define beacon-records
  (~> (fetch-aoc-input (find-session) 2022 15 #:cache #true)
      (string-split "\n")
      (map (λ~> (string-replace #px"[^\\d\\s-]" "")
                string-split
                (map string->number _)
                (chunks-of 2)
                (map (apply posn _) _)
                (apply beacon-record _))
           _)))

(define (manhattan-distance-to-beacon record)
  (match-define (beacon-record (posn sx sy) (posn bx by)) record)
  (+ (abs (- sx bx)) (abs (- sy by))))

(define (coverage-at-row record row)
  (match-define (beacon-record (posn sx sy) _) record)
  (define x-distance (- (manhattan-distance-to-beacon record) (abs (- row sy))))
  (cond
    [(negative? x-distance) (iset-make-range)]
    [else (iset-make-range (- sx x-distance) (+ sx x-distance))]))

(define (total-coverage-at-row records row)
  (for/fold ([coverage (iset-make-range)]) ([r (in-list records)])
    (iset-union coverage (coverage-at-row r row))))

;; part 1
(define (coverage-without-beacons records row)
  (~> (total-coverage-at-row records row)
      iset-count
      (- (count (λ (b) (= row (posn-y b)))
                (~> beacon-records (map beacon-record-beacon _) remove-duplicates)))))

(coverage-without-beacons beacon-records 2000000)

;; part 2
(define (find-only-beacon beacon-records size)
  (for/first ([y (in-range 0 size)]
              #:do [(define xs (iset-complement (total-coverage-at-row beacon-records y) 0 size))]
              #:when (= 1 (iset-count xs)))
    (+ (* 4000000 (iset-get-integer xs)) y)))

(find-only-beacon beacon-records 4000000)

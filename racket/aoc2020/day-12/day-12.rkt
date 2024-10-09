#lang rackjure

(require advent-of-code
         threading
         (only-in relation ->symbol ->number))

(struct instruction (direction distance) #:transparent)

(define (parse-instruction str)
  (match str
    [(regexp #px"(\\w)(\\d+)" (list _ dir dist)) (instruction (->symbol dir) (->number dist))]))

(define instructions
  (~>> (fetch-aoc-input (find-session) 2020 12) string-split (map parse-instruction)))

;; part 1
(struct boat (x y nav) #:transparent)

(define (angle->direction n)
  (case n
    [(0) 'E]
    [(90) 'N]
    [(180) 'W]
    [(270) 'S]))

(define (move-via-direct-command inst b)
  (match-define (boat x y facing) b)
  (match inst
    [(instruction 'N n) (boat x (+ y n) facing)]
    [(instruction 'S n) (boat x (- y n) facing)]
    [(instruction 'E n) (boat (+ x n) y facing)]
    [(instruction 'W n) (boat (- x n) y facing)]
    [(instruction 'L n) (boat x y (modulo (+ facing n) 360))]
    [(instruction 'R n) (boat x y (modulo (- facing n) 360))]
    [(instruction 'F n) (move-via-direct-command (instruction (angle->direction facing) n) b)]))

(define (find-boat-destination using start instructions)
  (match-define (boat x y _) (foldl using start instructions))
  (+ (abs x) (abs y)))

(find-boat-destination move-via-direct-command (boat 0 0 0) instructions)

;; part 2
(define (move-via-waypoint inst b)
  (match-define (boat x y (cons wp-x wp-y)) b)
  (match inst
    [(instruction 'N n) (boat x y (cons wp-x (+ wp-y n)))]
    [(instruction 'S n) (boat x y (cons wp-x (- wp-y n)))]
    [(instruction 'E n) (boat x y (cons (+ wp-x n) wp-y))]
    [(instruction 'W n) (boat x y (cons (- wp-x n) wp-y))]
    [(instruction _ 180) (boat x y (cons (- wp-x) (- wp-y)))]
    [(or (instruction 'L 90) (instruction 'R 270)) (boat x y (cons (- wp-y) wp-x))]
    [(or (instruction 'R 90) (instruction 'L 270)) (boat x y (cons wp-y (- wp-x)))]
    [(instruction 'F n) (boat (+ x (* n wp-x)) (+ y (* n wp-y)) (cons wp-x wp-y))]))

(find-boat-destination move-via-waypoint (boat 0 0 '(10 . 1)) instructions)

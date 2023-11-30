#lang racket
(require "../../jj-aoc.rkt"
         threading)

(struct pixel (i j) #:transparent)

(define-values (raw-enhancement raw-image)
  (~> (open-day 20 2021) port->string (string-split "\n\n") (apply values _)))

(define (char->pixel c)
  (if (char=? #\# c) 'light 'dark))
(define (pixel->char c)
  (if (equal? 'light c) #\# #\.))

(define enhancement-algorithm
  (for/hash ([(c i) (in-indexed (~> raw-enhancement (string-replace "\n" "")))])
    (values i (char->pixel c))))

(define image-hash
  (for*/hash ([(row i) (in-indexed (string-split raw-image "\n"))] [(c j) (in-indexed row)])
    (values (pixel i j) (char->pixel c))))

(define (window->new-pixel p ps bg)
  (match-define (pixel i j) p)
  (~> (for*/list ([di '(-1 0 1)] [dj '(-1 0 1)])
        (if (equal? 'dark (hash-ref ps (pixel (+ i di) (+ j dj)) bg)) #\0 #\1))
      (apply string _)
      (string->number _ 2)
      (hash-ref enhancement-algorithm _)))

(define (pad-hash ps bg)
  (define coords (hash-keys ps))
  (define i-min (~>> coords (map pixel-i) (apply min)))
  (define i-max (~>> coords (map pixel-i) (apply max)))
  (define j-min (~>> coords (map pixel-j) (apply min)))
  (define j-max (~>> coords (map pixel-j) (apply max)))
  (for*/hash ([i (in-inclusive-range (- i-min 2) (+ i-max 2))]
              [j (in-inclusive-range (- j-min 2) (+ j-max 2))])
    (values (pixel i j) (hash-ref ps (pixel i j) bg))))

(define (enhance-image ps bg)
  (for/hash ([(p _) (in-hash (pad-hash ps bg))])
    (values p (window->new-pixel p ps bg))))

;; part 1
;; looking at the enhancement algorithm, since a window of 0 -> light and 512 -> dark,
;; the infinite background flips colors every other enhancement step
;; instead of trying to account for this algorithmically I just hardcoded it in
(~> image-hash
    (enhance-image 'dark)
    (enhance-image 'light)
    hash-values
    (count (curry equal? 'light) _))

;; part 2
(~> (for/fold ([img image-hash]) ([_ (in-range 25)])
      (~> img (enhance-image 'dark) (enhance-image 'light)))
    hash-values
    (count (curry equal? 'light) _))

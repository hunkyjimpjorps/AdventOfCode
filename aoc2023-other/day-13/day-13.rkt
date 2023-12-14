#lang racket

(require advent-of-code
         threading)

(define input
  (~>(fetch-aoc-input (find-session) 2023 13 #:cache #true)
     (string-split "\n\n")
     (map (λ~> string-split) _)))

(define (do-symmetric? lefts rights errs)
  (cond
    [(empty? rights) #f]
    [else
     (define found-errs
       (for/sum ([l (in-string (string-join lefts ""))]
                 [r (in-string (string-join rights ""))]
                 #:unless (char=? l r))
         1))
     (if (= errs found-errs)
         (length lefts)
         (do-symmetric? (cons (first rights) lefts)
                        (rest rights)
                        errs))]))

(define (symmetric? xss errs)
  (do-symmetric? (list (first xss)) (rest xss) errs))

(define (transpose strs)
  (~> strs
      (map string->list _)
      (apply map list _)
      (map list->string _)))

(define (find-symmetry-score xss errs)
  (cond
    [(symmetric? xss errs) => (curry * 100)]
    [else (symmetric? (transpose xss) errs)]))

;; part 1
(for/sum ([note (in-list input)])
  (find-symmetry-score note 0))

;; part 2
(for/sum ([note (in-list input)])
  (find-symmetry-score note 1))


#lang racket

(require advent-of-code)

(struct posn (r c) #:transparent)

(define (make-tree-grid data)
  (for*/hash ([(row r) (in-indexed data)] [(col c) (in-indexed (in-string row))])
    (values (posn r c) (string->number (string col)))))

(define tree-grid (make-tree-grid (in-lines (open-aoc-input (find-session) 2022 8))))

;; part 1

(define (can-see-to-outside? p height dr dc h)
  (match-define (posn r c) p)
  (not (for/first ([n (in-naturals 1)]
                   #:do [(define p* (posn (+ r (* n dr)) (+ c (* n dc))))]
                   #:break (not (hash-has-key? h p*))
                   #:when (<= height (hash-ref h p*)))
         #true)))

(define (visible-in-any-direction? p height h)
  (for*/or ([dr (in-list '(-1 0 1))] [dc (in-list '(-1 0 1))] #:when (= 1 (abs (+ dr dc))))
    (can-see-to-outside? p height dr dc h)))

(define (count-visible-trees trees)
  (for/sum ([(tree-posn height) (in-hash trees)])
           (cond
             [(visible-in-any-direction? tree-posn height trees) 1]
             [else 0])))

(count-visible-trees tree-grid)

;; part 2

(define (scenic-score-in-direction p height dr dc h)
  (match-define (posn r c) p)
  (define score
    (for/last ([n (in-naturals 1)]
               #:do [(define p* (posn (+ r (* n dr)) (+ c (* n dc))))]
               #:break (not (hash-has-key? h p*))
               #:final (<= height (hash-ref h p*)))
      n))
  (if (not score) 0 score))

(define (scenic-score p height h)
  (for*/product ([dr (in-list '(-1 0 1))] [dc (in-list '(-1 0 1))] #:when (= 1 (abs (+ dr dc))))
                (scenic-score-in-direction p height dr dc h)))

(define (find-best-scenic-score trees)
  (apply max
         (for/list ([(tree-posn height) (in-hash trees)])
           (scenic-score tree-posn height trees))))

(find-best-scenic-score tree-grid)

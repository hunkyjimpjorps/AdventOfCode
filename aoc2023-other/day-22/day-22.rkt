#lang racket

(require advent-of-code
         threading
         data/applicative
         data/monad
         megaparsack
         megaparsack/text
         racket/hash)

(struct posn (x y z) #:transparent)
(struct block (n from to) #:transparent)

(define input (fetch-aoc-input (find-session) 2023 22 #:cache #true))

(define coordinate/p
  (do [coords <- (many/p integer/p #:sep (char/p #\,) #:min 3 #:max 3)] (pure (apply posn coords))))

(define block/p (do [from <- coordinate/p] (char/p #\~) [to <- coordinate/p] (pure (cons from to))))

(define starting-blocks
  (~> (for/list ([line (in-list (string-split input "\n"))]
                 [n (in-naturals)])
        (match-define (cons from to) (parse-result! (parse-string block/p line)))
        (block n from to))
      (sort < #:key (λ~> block-from posn-z))))

(define (all-in-cross-section-at-level b z)
  (match-define (block _ (posn x1 y1 _) (posn x2 y2 _)) b)
  (for*/list ([x (in-inclusive-range x1 x2)]
              [y (in-inclusive-range y1 y2)])
    (posn x y z)))

(define (place-block-at-level b h dz)
  (match-define (block n (posn x1 y1 z1) (posn x2 y2 z2)) b)
  (define now-occupied
    (for*/hash ([x (in-inclusive-range x1 x2)]
                [y (in-inclusive-range y1 y2)]
                [z (in-inclusive-range dz (+ dz (- z2 z1)))])
      (values (posn x y z) n)))
  (hash-union h now-occupied))

(define (find-lowest-level b h [z (~> b block-from posn-z)])
  (cond
    [(= z 0)
     (place-block-at-level b h 1)]
    [(findf (curry hash-has-key? h) (all-in-cross-section-at-level b z))
     (place-block-at-level b h (add1 z))]
    [else
     (find-lowest-level b h (sub1 z))]))

(define blocks-in-space (foldl find-lowest-level (hash) starting-blocks))
(define block-positions
  (for/fold ([placed-blocks (hash)])
            ([(p n) (in-hash blocks-in-space)])
    (hash-update placed-blocks n (curryr set-add p) (set))))

(define (down-one p)
  (match p
    [(posn x y z) (posn x y (sub1 z))]))

(define supporting-blocks
  (for/hash ([(n-id n-posns) (in-hash block-positions)])
    (values n-id
            (for*/set ([(m-id m-posns) (in-hash block-positions)]
                       #:unless (= n-id m-id)
                       [m-posn (in-set m-posns)]
                       #:when (set-member? n-posns (down-one m-posn)))
              m-id))))

(define supported-by-blocks
  (for/hash ([n-id (in-hash-keys supporting-blocks)])
    (define supporters
      (~> (for*/set
              ([(m-id m-supporting) (in-hash supporting-blocks)]
               #:unless (= n-id m-id)
               #:when (set-member? m-supporting n-id))
            m-id)
          ((λ (s) (if (set-empty? s) (set 'ground) s)))))
    (values n-id supporters)))

;; part 1
(define vulnerable-blocks
  (for/list ([n-id (in-range (length starting-blocks))]
             #:when (for/or ([m-supported-by (in-hash-values supported-by-blocks)])
                      (set-empty? (set-remove m-supported-by n-id))))
    n-id))
(- (length starting-blocks) (length vulnerable-blocks))

;; part 2
(for/sum ([n (in-list vulnerable-blocks)])
  (for/fold ([fallen (set n)]
             [bricks (set n)]
             #:result (~> fallen set-count sub1))
            ([_ (in-naturals)])
    #:break (set-empty? bricks)
    (define bricks-above
      (for*/set
          ([brick (in-set bricks)]
           [supporting (in-set (hash-ref supporting-blocks brick))]
           #:when (for/and ([supports (in-set (hash-ref supported-by-blocks supporting))])
                    (set-member? fallen supports)))
        supporting))
    (values (set-union fallen bricks-above) bricks-above)))
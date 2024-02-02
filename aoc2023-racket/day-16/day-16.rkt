#lang racket

(require advent-of-code
         threading)

(struct posn (r c) #:transparent)
(struct light (posn dir) #:transparent)

(define input (fetch-aoc-input (find-session) 2023 16 #:cache #true))

(define grid
  (for*/hash ([(row r) (in-indexed (string-split input "\n"))]
              [(cell c) (in-indexed (in-string row))])
    (values (posn r c) cell)))

(define/match (move _l)
  [((light (posn r c) 'up)) (light (posn (sub1 r) c) 'up)]
  [((light (posn r c) 'right)) (light (posn r (add1 c)) 'right)]
  [((light (posn r c) 'left)) (light (posn r (sub1 c)) 'left)]
  [((light (posn r c) 'down)) (light (posn (add1 r) c) 'down)])

(define/match (transform l _cell)
  [(_ #\.) l]
  [(_ 'off) '()]

  [((light _ (or 'up 'down)) #\|) l]
  [((light _ (or 'left 'right)) #\-) l]

  [((light p 'left) #\/) (light p 'down)]
  [((light p 'down) #\/) (light p 'left)]
  [((light p 'right) #\/) (light p 'up)]
  [((light p 'up) #\/) (light p 'right)]

  [((light p 'left) #\\) (light p 'up)]
  [((light p 'up) #\\) (light p 'left)]
  [((light p 'right) #\\) (light p 'down)]
  [((light p 'down) #\\) (light p 'right)]

  [((light p (or 'left 'right)) #\|) (list (light p 'up) (light p 'down))]
  [((light p (or 'up 'down)) #\-) (list (light p 'left) (light p 'right))])

;; part 1
(define (get-energized start)
  (for/fold ([energized (set)]
             [previously-visited (set)]
             [beam-tips (set start)]
             #:result (set-count energized))
            ([_ (in-naturals)])
    (define next-positions
      (list->set
       (flatten (for/list ([b (in-set beam-tips)])
                  (~> b move ((λ (b) (transform b (hash-ref grid (light-posn b) 'off)))))))))
    (define all-visited (set-union previously-visited next-positions))
    (define next-energized (set-union energized (list->set (set-map next-positions light-posn))))
    #:break (equal? previously-visited all-visited)
    (values next-energized all-visited (set-subtract next-positions previously-visited))))

(get-energized (light (posn 0 -1) 'right))

;; part 2
(define rows (~> input (string-split "\n") length))
(define cols (~> input (string-split #rx"\n.*") first string-length))

(define all-starting-positions
  (append (map (λ (r) (light (posn r -1) 'right)) (range rows))
          (map (λ (r) (light (posn r cols) 'left)) (range rows))
          (map (λ (c) (light (posn -1 c) 'down)) (range cols))
          (map (λ (c) (light (posn rows c) 'up)) (range cols))))

(get-energized (argmax get-energized all-starting-positions))
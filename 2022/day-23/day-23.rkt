#lang racket

(require advent-of-code
         fancy-app
         threading)

(define elf-map (in-lines (open-aoc-input (find-session) 2022 23 #:cache #true)))

(struct posn (x y) #:transparent)

(define initial-map
  (for*/hash ([(row y) (in-indexed elf-map)] [(col x) (in-indexed row)] #:when (equal? col #\#))
    (values (posn x y) #t)))

(define (count-empty-spots elves)
  (define elf-posns (hash-keys elves))
  (match-define (list x-min _ ... x-max) (sort (map posn-x elf-posns) <))
  (match-define (list y-min _ ... y-max) (sort (map posn-y elf-posns) <))
  (for*/sum ([y (inclusive-range y-min y-max)] [x (inclusive-range x-min x-max)])
            (if (hash-has-key? elves (posn x y)) 0 1)))

(define/match (neighbors-in direction p)
  [('north (posn x (app sub1 y*))) (list (posn (sub1 x) y*) (posn x y*) (posn (add1 x) y*))]
  [('south (posn x (app add1 y*))) (list (posn (sub1 x) y*) (posn x y*) (posn (add1 x) y*))]
  [('east (posn (app add1 x*) y)) (list (posn x* (add1 y)) (posn x* y) (posn x* (sub1 y)))]
  [('west (posn (app sub1 x*) y)) (list (posn x* (add1 y)) (posn x* y) (posn x* (sub1 y)))])

(define/match (move-to direction p)
  [('stay p) p]
  [('north (posn x y)) (posn x (sub1 y))]
  [('south (posn x y)) (posn x (add1 y))]
  [('east (posn x y)) (posn (add1 x) y)]
  [('west (posn x y)) (posn (sub1 x) y)])

(define (propose-movements elves dirs)
  (for/hash ([(elf _) (in-hash elves)])
    (define dir-candidates
      (for/list ([dir dirs]
                 #:do [(define neighbors (neighbors-in dir elf))]
                 #:unless (ormap (curry hash-has-key? elves) neighbors))
        dir))
    (define chosen-dir
      (match dir-candidates
        ['() 'stay]
        [(== dirs) 'stay]
        [(cons dir _) dir]))
    (values elf chosen-dir)))

(define (try-proposed-movements elves)
  (define moved-elves (make-hash))
  (for ([(elf dir) (in-hash elves)])
    (hash-update! moved-elves (move-to dir elf) (cons elf _) '()))
  (define reconciled-elves (make-hash))
  (for ([(posn elves) (in-hash moved-elves)])
    (match elves
      [(list _) (hash-set! reconciled-elves posn #t)]
      [many-elves
       (for ([elf (in-list many-elves)])
         (hash-set! reconciled-elves elf #t))]))
  reconciled-elves)

;; part 1
(for/fold ([elves initial-map] [dirs '(north south west east)] #:result (count-empty-spots elves))
          ([_rnd (in-range 10)])
  (values (~> elves (propose-movements dirs) try-proposed-movements)
          (append (cdr dirs) (list (car dirs)))))

;; part 2
(time (for/fold ([elves initial-map] [dirs '(north south west east)] [rnd 1] #:result rnd)
          ([_rnd (in-naturals)])
  (define elves-proposed (propose-movements elves dirs))
  #:break (~> elves-proposed hash-values remove-duplicates (equal? '(stay)))
  (values (try-proposed-movements elves-proposed) (append (cdr dirs) (list (car dirs))) (add1 rnd))))

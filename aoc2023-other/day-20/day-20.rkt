#lang racket

(require advent-of-code
         threading
         data/applicative
         data/monad
         megaparsack
         megaparsack/text
         struct-update)

(struct broadcaster ())
(struct flipflop (state received) #:transparent)
(struct conjunction (recieved) #:transparent)
(struct cable (type dests) #:transparent)
(struct nothing ())

(define-struct-updaters flipflop)
(define-struct-updaters conjunction)

(define charlist->symbol (λ~>> (apply string) string->symbol))

(define input (fetch-aoc-input (find-session) 2023 20 #:cache true))

(define module/p
  (do (or/p (do (char/p #\%)
              [name <- (many+/p letter/p)]
              (pure (cons (charlist->symbol name) (flipflop 'off '()))))
            (do (char/p #\&)
              [name <- (many+/p letter/p)]
              (pure (cons (charlist->symbol name) (conjunction (hash)))))
            (do [name <- (many+/p letter/p)] (pure (cons (charlist->symbol name) (broadcaster)))))))

(define cable/p
  (do [mod <- module/p]
    (string/p " -> ")
    [names <- (many/p (many+/p letter/p) #:sep (string/p ", "))]
    (pure (cable mod (map charlist->symbol names)))))

(define cables (~> input (string-split "\n") (map (λ~>> (parse-string cable/p) parse-result!) _)))

(define destinations
  (for/hash ([cable (in-list cables)])
    (values (car (cable-type cable)) (cable-dests cable))))

(define (make-initial-conditions-hash cables)
  (~> cables
      (map cable-type _)
      (map (λ (c)
             (cond
               [(conjunction? (cdr c))
                (~> destinations
                    hash-keys
                    (filter (λ (k) (member (car c) (hash-ref destinations k))) _)
                    (map (λ (k) (cons k 'low)) _)
                    (make-immutable-hash)
                    (conjunction)
                    (cons (car c) _))]
               [else c]))
           _)
      make-immutable-hash))

(define (receive mod from tone)
  (match mod
    [(flipflop state queue) (flipflop state (append queue (list tone)))]
    [(conjunction received) (conjunction (hash-set received from tone))]
    [(nothing) (nothing)]))

; needed for part 2
(define to-rx '(rk cd zf qx))
(define sentry-tones (make-hash (for/list ([node to-rx]) (cons node 0))))

(define (press-button-once current-state this-round)
  (for/fold ([queue '(broadcaster)]
             [all-cables-state current-state]
             [high 0]
             [low 0]
             #:result (values all-cables-state high low))
            ([_i (in-naturals)] #:break (empty? queue))
    (match-define (list* hd tl) queue)
    (define to (hash-ref destinations hd (nothing)))
    (match (hash-ref all-cables-state hd)
      [(broadcaster)
       (define state*
         (foldl (λ (r acc) (hash-update acc r (λ~> (receive hd 'low)) (nothing)))
                all-cables-state
                to))
       (values (hash-ref destinations 'broadcaster) state* high (+ (length to) (add1 low)))]
      [(flipflop 'off (list* 'low q))
       (define state*
         (~> all-cables-state
             (foldl (λ (r acc)
                      (when (member r to-rx)
                        (println (~a r " received high tone at " this-round)))
                      (hash-update acc r (λ~> (receive hd 'high)) (nothing)))
                    _
                    to)
             (hash-set _ hd (flipflop 'on q))))
       (values (append tl to) state* (+ (length to) high) low)]
      [(flipflop 'on (list* 'low q))
       (define state*
         (~> all-cables-state
             (foldl (λ (r acc) (hash-update acc r (λ~> (receive hd 'low)) (nothing))) _ to)
             (hash-set _ hd (flipflop 'off q))))
       (values (append tl to) state* high (+ (length to) low))]
      [(flipflop on-or-off (list* 'high q))
       (define state* (~> all-cables-state (hash-set _ hd (flipflop on-or-off q))))
       (values tl state* high low)]
      [(conjunction received)
       #:when (or (empty? (hash-values received)) (member 'low (hash-values received)))

       (when (member hd to-rx)
         (hash-set! sentry-tones hd this-round))
       (define state*
         (foldl (λ (r acc)
                  (hash-update acc r (λ~> (receive hd 'high)) (nothing)))
                all-cables-state
                to))
       (values (append to tl) state* (+ (length to) high) low)]
      [(conjunction _)
       (define state*
         (foldl (λ (r acc) (hash-update acc r (λ~> (receive hd 'low)) (nothing)))
                all-cables-state
                to))
       (values (append tl to) state* high (+ (length to) low))]
      [(nothing) (values tl all-cables-state high low)])))

;; part 1
(for/fold ([starting-state (make-initial-conditions-hash cables)]
           [high 0]
           [low 0]
           #:result (* high low))
          ([i (in-range 1000)])
  (define-values (next-state this-high this-low) (press-button-once starting-state i))
  (values next-state  (+ high this-high) (+ low this-low)))

;; part 2
;; rx receives a tone from gh, which receives four tones itself
;; those tones arrive on regular synced cycles so it's just the LCM of those cycle lengths
;; and since those cycle lengths are prime, it reduces to the product of the lengths
;; this is a really hacky mutable solution, I'm sure there's better ways of flagging these cycles

(for/fold ([starting-state (make-initial-conditions-hash cables)]
           #:result (apply * (hash-values sentry-tones)))
          ([i (in-range 1 5000)])
  (define-values (next-state _high _low) (press-button-once starting-state i))
  (values next-state))
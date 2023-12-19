#lang racket

(require advent-of-code
         threading
         data/applicative
         data/monad
         megaparsack
         megaparsack/text
         racket/struct)

(struct part (x m a s) #:transparent)
(struct rule (rating comparison threshold action) #:transparent)
(struct just (action) #:transparent)
(struct interval (from to) #:transparent)

(match-define (list raw-workflows raw-parts)
  (~> (fetch-aoc-input (find-session) 2023 19 #:cache #true)
      (string-split "\n\n")
      (map (curryr string-split "\n") _)))

(define/match (to-getter _)
  [(#\x) part-x]
  [(#\m) part-m]
  [(#\a) part-a]
  [(#\s) part-s])

(define/match (to-comp _)
  [(#\>) >]
  [(#\<) <])

(define/match (to-action _)
  [('(#\R)) 'reject]
  [('(#\A)) 'accept]
  [(name) (apply string name)])

(define rule/p
  (do (or/p
       (try/p (do [rating <- (char-in/p "xmas")]
                [comparison <- (char-in/p "<>")]
                [threshold <- integer/p]
                (char/p #\:)
                [action <- (many+/p letter/p)]
                (pure (rule (to-getter rating)
                            (to-comp comparison)
                            threshold
                            (to-action action)))))
       (do [name <- (many+/p letter/p)] (pure (just (to-action name)))))))
(define rules/p
  (do [name <- (many+/p letter/p)]
    (char/p #\{)
    [rules <- (many+/p rule/p #:sep (char/p #\,))]
    (char/p #\})
    (pure (cons (list->string name) rules))))

(define rating/p (do letter/p (char/p #\=) integer/p))
(define parts/p
  (do (string/p "{")
    [ratings <- (many/p rating/p #:sep (char/p #\,) #:min 4 #:max 4)]
    (string/p "}")
    (pure (apply part ratings))))

(define workflows
  (~>> raw-workflows
       (map (λ~>> (parse-string rules/p) parse-result!))
       make-immutable-hash))
(define parts (map (λ~>> (parse-string parts/p) parse-result!) raw-parts))

;; part 1

(define (evaluate-workflow p [workflow-name "in"])
  (define rules (hash-ref workflows workflow-name))
  (match (evaluate-rules p rules)
    ['accept (~> p struct->list (apply + _))]
    ['reject 0]
    [name (evaluate-workflow p name)]))

(define (evaluate-rules p rules)
  (match rules
    [(list* (just action) _) action]
    [(list* (rule rating comparison threshold action) _)
     #:when (comparison (rating p) threshold)
     action]
    [(list* _ tail) (evaluate-rules p tail)]))

(for/sum ([p (in-list parts)]) (evaluate-workflow p))

;; part 2

(define (part-update-range pr rating i)
  (match rating
    [(== part-x) (struct-copy part pr (x i))]
    [(== part-m) (struct-copy part pr (m i))]
    [(== part-a) (struct-copy part pr (a i))]
    [(== part-s) (struct-copy part pr (s i))]))

(define (evaluate-workflow-on-range pr [workflow-name "in"])
  (define rules (hash-ref workflows workflow-name))
  (evaluate-rules-on-range pr rules))

(define (evaluate-rules-on-range pr rules)
  (match rules
    [(list* (just 'accept) _)
     (~> pr struct->list
         (map (λ (i) (add1 (- (interval-to i) (interval-from i)))) _)
         (apply * _))]
    [(list* (just 'reject) _) 0]
    [(list* (just name) _) (evaluate-workflow-on-range pr name)]
    [(list* (rule rating (== <) threshold action) tail)
     (match-define (interval i-min i-max) (rating pr))
     (split-range pr
                  rating
                  (interval i-min (sub1 threshold))
                  action
                  (interval threshold i-max)
                  tail)]
    [(list* (rule rating (== >) threshold action) tail)
     (match-define (interval i-min i-max) (rating pr))
     (split-range pr
                  rating
                  (interval (add1 threshold) i-max)
                  action
                  (interval i-min threshold)
                  tail)]))

(define (split-range pr rating keep action pass rules)
  (+ (evaluate-rules-on-range (part-update-range pr rating keep)
                              (list (just action)))
     (evaluate-rules-on-range (part-update-range pr rating pass)
                              rules)))

(define start-interval (interval 1 4000))

(evaluate-workflow-on-range
 (part start-interval start-interval start-interval start-interval))

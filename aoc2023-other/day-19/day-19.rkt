#lang racket

(require advent-of-code
         threading
         data/applicative
         data/monad
         megaparsack
         megaparsack/text)

(struct part (x m a s) #:transparent)
(struct rule (rating comparison threshold action) #:transparent)
(struct just (action) #:transparent)
(struct interval (from to))

(match-define (list raw-rules raw-parts)
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
                  (pure (rule (to-getter rating) (to-comp comparison) threshold (to-action action)))))
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

(define rules (~>> raw-rules (map (λ~>> (parse-string rules/p) parse-result!)) make-immutable-hash))
(define parts (map (λ~>> (parse-string parts/p) parse-result!) raw-parts))

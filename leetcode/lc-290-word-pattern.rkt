#lang racket
(define match-string "abba")
(define a "dog")
(define b "cat")
(define Σ "dog cat cat dog")

(define/contract (word-pattern pattern s)
  (-> string? string? boolean?)
  (define pattern-list (map string (string->list pattern)))
  (define s-list (string-split s))
  (define match-hash (make-hash))
  (if (= (length pattern-list) (length s-list))
      (for/and ([pattern-part pattern-list]
                [s-part s-list])
        (cond [(and (not (hash-has-key? match-hash pattern-part))
                    (member s-part (hash-values match-hash))) #f]
              [(not (hash-has-key? match-hash pattern-part))
               (hash-set! match-hash pattern-part s-part) #t] 
              [(string=? (hash-ref match-hash pattern-part) s-part) #t]
              [else #f]))
      #f))

(word-pattern match-string Σ) 
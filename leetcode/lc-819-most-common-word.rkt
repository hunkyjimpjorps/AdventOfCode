#lang racket
(define/contract (most-common-word paragraph banned)
  (-> string? (listof string?) string?)
  (define word-count-hash (make-hash))
  (define banned-word-hash
    (apply hash (flatten (map (λ (w) (cons w 'banned)) banned))))
  (define word-list
    ((compose string-split string-downcase)
     (string-replace paragraph #px"[^A-Za-z[:space:]]" " ")))
  (for/list ([word (in-list word-list)])
    (cond [(hash-has-key? banned-word-hash word) void]
          [else (hash-update! word-count-hash word add1 0)]))
  (car (argmax cdr (hash->list word-count-hash))))


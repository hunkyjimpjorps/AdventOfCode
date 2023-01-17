#lang racket

(define/contract (is-alien-sorted words order)
  (-> (listof string?) string? boolean?)
  (define alpha-order
    (make-hash (map (λ (a b) (cons a b))
                    (map string (string->list order))
                    (build-list (string-length order) identity))))
  (hash-set! alpha-order #\* -1)
  (define (alien<? s1 s2)
    (cond [(equal? s1 "") #true]
          [(equal? s2 "") #false]
          [(equal? (hash-ref alpha-order (substring s1 0 1))
                   (hash-ref alpha-order (substring s2 0 1)))
           (alien<? (substring s1 1 (string-length s1))
                    (substring s2 1 (string-length s2)))]
          [(< (hash-ref alpha-order (substring s1 0 1))
              (hash-ref alpha-order (substring s2 0 1))) #true]
          [else false]))
  (equal? words
          (sort words alien<?)))

(is-alien-sorted '["hello" "leetcode"] "hlabcdefgijkmnopqrstuvwxyz")
(is-alien-sorted '["word" "world" "row"] "worldabcefghijkmnpqstuvxyz")
(is-alien-sorted '["apple" "app"] "abcdefghijklmnopqrstuvwxyz")
(is-alien-sorted '["iekm" "tpnhnbe"] "loxbzapnmstkhijfcuqdewyvrg")
#lang racket

(define keyboard-rows (list "qwertyuiop" 
                            "asdfghjkl" 
                            "zxcvbnm"))

(define keyboard-row-sets
  (for/list ([row keyboard-rows])
    (list->set (map string (string->list row)))))

(define/contract (find-words words)
  (-> (listof string?) (listof string?))
  (define word-checks
    (for/list ([w words])
      (define word-set
        (list->set (map string (string->list (string-downcase w)))))
      (if (for/or ([row keyboard-row-sets])
            (subset? word-set row))
          w
          '())))
  (filter-not empty? word-checks))

(find-words '("Hello" "Alaska" "Dad" "Peace"))
#lang racket
(define word-filter%
  (class object%
    (super-new)

    ; words : (listof string?)
    (init-field
     words)                                                 ; Take in the provided dictionary.
    (define word-ends-hash (make-hash))                     ; Make an empty hash table.
    
    (for/list ([w (in-list words)]                          ; For each word in the dictionary,
               [index (in-naturals)])                       ; and its corresponding index,
      (define len (string-length w))                        ; calculate its length,
      (for*/list ([head (in-range 1 (min 11 (add1 len)))]   ; and for every combination of head length
                  [tail (in-range 1 (min 11 (add1 len)))])  ; and tail length 
        (hash-set! word-ends-hash                           ; from 1 to the max. affix length,
                   (list (substring w 0 head)               ; set the key to the list containing
                         (substring w (- len tail) len))    ; the prefix and suffix
                   index)))                                 ; and map it to the word's index.
    
    ; f : string? string? -> exact-integer?
    (define/public (f prefix suffix)                        ; Return the mapped value for the affixes
      (hash-ref word-ends-hash (list prefix suffix) -1))))  ; or -1 if it doesn't exist.

;; Your word-filter% object will be instantiated and called as such:
;; (define obj (new word-filter% [words words]))
;; (define param_1 (send obj f prefix suffix))
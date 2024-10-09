#lang racket

(define/contract (check-record s)
  (-> string? boolean?)
  (define s-list (map string (string->list s)))
  (cond [(<= 2 (count (curry string=? "A") s-list)) #false]
        [(string-contains? s "LLL") #false]
        [else #true]))

(check-record "PPALLP")
(check-record "PPALLL")
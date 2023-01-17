#lang racket

(define (pos board r c)
  (list-ref (list-ref board r) c))

(define (scan-for-duplicates array)
  (andmap (λ (row) (not (check-duplicates row))) 
          (map (curry filter-not (curry equal? ".")) array)))

(define (check-rows board)
  (scan-for-duplicates board))

(define (check-cols board)
  (scan-for-duplicates (apply map list board)))

(define (check-boxes board)
  (define boxes-to-lists
    (for*/list ([r (in-list '(0 3 6))]
                [c (in-list '(0 3 6))])
      (for*/list ([box-r (in-range r (+ r 3))]
                  [box-c (in-range c (+ c 3))]
                  #:unless (equal? "." (pos board box-r box-c)))
        (pos board box-r box-c))))
  (scan-for-duplicates boxes-to-lists))

(define/contract (is-valid-sudoku board)
  (-> (listof (listof string?)) boolean?)
  (and (check-rows board)
       (check-cols board)
       (check-boxes board)))

(define valid-sudoku '[["5" "3" "." "." "7" "." "." "." "."] ["6" "." "." "1" "9" "5" "." "." "."] ["." "9" "8" "." "." "." "." "6" "."] ["8" "." "." "." "6" "." "." "." "3"] ["4" "." "." "8" "." "3" "." "." "1"] ["7" "." "." "." "2" "." "." "." "6"] ["." "6" "." "." "." "." "2" "8" "."] ["." "." "." "4" "1" "9" "." "." "5"] ["." "." "." "." "8" "." "." "7" "9"]]) 
(define invalid-sudoku '[["8" "3" "." "." "7" "." "." "." "."] ["6" "." "." "1" "9" "5" "." "." "."] ["." "9" "8" "." "." "." "." "6" "."] ["8" "." "." "." "6" "." "." "." "3"] ["4" "." "." "8" "." "3" "." "." "1"] ["7" "." "." "." "2" "." "." "." "6"] ["." "6" "." "." "." "." "2" "8" "."] ["." "." "." "4" "1" "9" "." "." "5"] ["." "." "." "." "8" "." "." "7" "9"]])
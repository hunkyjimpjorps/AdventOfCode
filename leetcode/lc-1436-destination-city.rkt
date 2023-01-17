#lang racket
(define/contract (dest-city paths)
  (-> (listof (listof string?)) string?)
  (define city-pairs (make-hash paths))
  (define (go-to-next-city origin)
    (let ([destination (hash-ref city-pairs origin #false)])
      (if destination
          (go-to-next-city (car destination))
          origin)))
  (go-to-next-city (caar paths)))

(dest-city '(("London" "New York")
             ("New York" "Lima")
             ("Lima" "Sao Paolo")))
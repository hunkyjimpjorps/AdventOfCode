#lang racket
(define/contract (maximum-population logs)
  (-> (listof (listof exact-integer?)) exact-integer?)
  ; make a hash table of every year encountered between the birth and death years
  (define population (make-hash))
  ; for each person in the logs,
  (for/list ([person (in-list logs)])
    ; for every year from birth to the year before death,
    (for/list ([year (in-range (first person) (second person))])
      ; look up the year in the hash table and add 1 to its key,
      ; or add the key and set its value to 1 if it doesn't exist yet
      (hash-update! population year add1 1)))
  ; convert the hash table to a list,
  ; sort the list by year,
  ; find the first element that maximizes the count,
  ; and return the associated year
  (car (argmax cdr (sort (hash->list population) < #:key car))))
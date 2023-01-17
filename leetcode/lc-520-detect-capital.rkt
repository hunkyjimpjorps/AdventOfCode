#lang racket

(define/contract (detect-capital-use word)
  (-> string? boolean?)
  (if 
   (member word (list (string-upcase word)
                      (string-downcase word)
                      (string-titlecase word)))
   #true
   #false))

(detect-capital-use "Google")
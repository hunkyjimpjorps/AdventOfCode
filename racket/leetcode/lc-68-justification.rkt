#lang racket
(define/contract (full-justify words max-width)
  (-> (listof string?) exact-integer? (listof string?))
  
  (define/contract (justify-line line [last-line #f])
    (->* ((listof string?)) (boolean?) string?)
    (define gaps (sub1 (length line)))
    (cond [last-line
           (~a (string-join line " ") #:min-width max-width)]       ; Right-pad the last line
          [(= 1 (length line))
           (~a (first line) #:min-width max-width)]                 ; Right-pad single-word lines
          [else
           (let* ([words-length (apply + (map string-length line))]
                  [spacing-length (- max-width words-length)]       ; How many spaces do we need?
                  [spacing-list (make-list gaps 1)]                 ; Every gap needs to be at least 
                  [distribute (- spacing-length gaps)]              ; 1 space long, so we need to
                  [distributed-spaces                               ; distribute the excess
                   (for/list ([space (in-list spacing-list)]
                              [i (in-naturals 1)])
                     (+ space
                        (quotient distribute gaps)                  ; Add an equal number of spaces 
                        (if (<= i                                   ; to each gap, then add the 
                                (modulo distribute gaps)) 1 0)))])  ; remainder at the front
             (apply string-append
                    (append (map (λ (w s)
                                   (string-append                   ; Knit together the first (n-1) 
                                    w (make-string s #\space)))     ; words and gaps, then append 
                                 (drop-right line 1)                ; the final word at the end
                                 distributed-spaces)
                            (take-right line 1))))]))
  
  (for/fold ([lines '()]                                            ; List of justified lines
             [line-acc '()]                                         ; Words to fit into the next line
             #:result (append lines                                 ; Only return the list of lines
                              (list (justify-line line-acc #t))))   ; and append the final line
            ([word (in-list words)])
    (let* ([candidate-acc (append line-acc (list word))]
           [candidate-length
            (string-length (string-join candidate-acc " "))])
      (if (candidate-length . <= . max-width)                       ; If the word fits into the line,
          (values lines                                             ; keep the current line list
                  candidate-acc)                                    ; and add it to the accumulator
          (values (append lines (list (justify-line line-acc)))     ; Otherwise, wrap up this line
                  (list word))))))                                  ; and start a new accumulator
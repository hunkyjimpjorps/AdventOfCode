#lang racket

(require advent-of-code
         fancy-app
         threading
         (only-in relation ->number))

(define command-output (~> (fetch-aoc-input (find-session) 2022 7) (string-split "\n")))

(define (parse-commands cmds)
  (define (update-sizes h path size)
    (match path
      ['() h]
      [(list* _ fs) (update-sizes (hash-update h path (+ _ size) 0) fs size)]))

  (for/fold ([folders (hash)] [current-path '()] [previously-seen? #false] #:result folders)
            ([cmd (in-list cmds)])
    (match (string-split cmd)
      [(list "$" "ls") (values folders current-path (hash-has-key? folders current-path))]
      [(list "$" "cd" "/") (values folders '("/") #false)]
      [(list "$" "cd" "..") (values folders (rest current-path) #false)]
      [(list "$" "cd" folder) (values folders (cons folder current-path) #false)]
      [(list "dir" _) (values folders current-path previously-seen?)]
      [(list (app ->number size) _)
       (cond
         [previously-seen? (values folders current-path previously-seen?)]
         [else (values (update-sizes folders current-path size) current-path previously-seen?)])])))

(define folders (parse-commands command-output))

;; part 1
(for/sum ([(_ v) (in-hash folders)] #:when (<= v 100000)) v)

;; part 2
(define required-to-delete (- 30000000 (- 70000000 (hash-ref folders '("/")))))
(~>> folders hash-values (filter (> _ required-to-delete)) (apply min))

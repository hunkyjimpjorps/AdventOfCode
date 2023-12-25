#lang racket

(require advent-of-code
         threading
         graph)

(define input
  (~> (fetch-aoc-input (find-session) 2023 25 #:cache #true)
      (string-split "\n")
      (map (curryr string-split ": ") _)))

(define all-wires
  (for*/list ([wire-diagram (in-list input)] [devices (in-list (string-split (second wire-diagram)))])
    (list (car wire-diagram) devices)))

;; instead of trying to solve the minimum cut problem, I generated the graph and
;; rendered it in graphviz:

; (define out (open-output-file "graphviz"))
; (~> all-wires
;     unweighted-graph/undirected
;     graphviz
;     (display out))
; (close-output-port out)

;; the bottleneck is very obvious on the graph --
;; there's two large clusters of nodes, connected by just three edges
;;
;; from the graphviz output, the three critical wires are
;; cpq-hlx
;; hqp-spk
;; chr-zlx

(define remove-these-three '(("cpq" "hlx") ("hqp" "spk") ("chr" "zlx")))
(define cut-wires
  (for/list ([wire (in-list all-wires)] #:unless (member (sort wire string<?) remove-these-three))
    wire))

(~> cut-wires
    unweighted-graph/undirected
    scc
    (map length _)
    (apply * _))
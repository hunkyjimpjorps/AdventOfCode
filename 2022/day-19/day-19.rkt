#lang racket

(require advent-of-code
         threading)

(struct blueprint (id ore clay obsidian geode))

(define (parse-line str)
  (match (~> str (string-replace #px"[^\\d\\s]" "") string-split)
    [(list id ore clay obsidian-ore obsidian-clay geode-ore geode-obsidian)
     (blueprint id ore clay (cons obsidian-ore obsidian-clay) (cons geode-ore geode-obsidian))]))

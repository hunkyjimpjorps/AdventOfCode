#lang racket

(require advent-of-code
         threading
         fancy-app
         relation
         rebellion/binary/bitstring)

(define instructions (string-split (fetch-aoc-input (find-session) 2020 14) "\n"))

(~> (number->string 11 2) ->list (map (->number _) _))

#lang racket
(require "../../jj-aoc.rkt"
         bitsyntax
         threading)

(struct packet (version id type value size)
  #:transparent)

(define (BITS->bitstring str)
  (integer->bit-string (string->number str 16)
                       (* 4 (string-length str))
                       #true))

(define data
  (~> (open-day 16 2021)
      port->string
      string-trim
      BITS->bitstring))

(define (overflow l w)
  (define extra (modulo l 4))
  (if (= extra 0) 0 (- w extra)))

(define (get-literal-contents bitstr)
  (for/fold ([assembled (bit-string)]
             [remaining bitstr]
             [total-length 6]
             [complete? #f]
             #:result (list (bit-string->integer assembled #t #f)
                            total-length
                            remaining))
            ([_ (in-naturals)]
             #:break complete?)
    (bit-string-case remaining
                     ([(= 1 :: bits 1) (number :: bits 4) (remaining :: binary)]
                      (values (bit-string-append assembled (integer->bit-string number 4 #t))
                              remaining
                              (+ total-length 5)
                              #f))
                     ([(= 0 :: bits 1)
                       (number :: bits 4)
                       (ignored :: bits (overflow (+ total-length 5) 4))
                       (remaining :: binary)]
                      (values (bit-string-append assembled (integer->bit-string number 4 #t))
                              remaining
                              (+ total-length 5)
                              #t)))))

(define (identify-next-packet bitstr)
  (bit-string-case bitstr
                   ([(packet-version :: bits 3)
                     (= 4 :: bits 3)
                     (remaining :: binary)]
                    (match-define (list n packet-length next-bitstr) (get-literal-contents remaining))
                    (list (packet packet-version
                                  4
                                  'literal
                                  n
                                  packet-length)
                          next-bitstr))
                   ([(packet-version :: bits 3)
                     (type-id :: bits 3)
                     (= 0 :: bits 1)
                     (subpacket-length :: bits 15)
                     (remaining :: binary)]
                    (list (packet packet-version type-id 'type-0-operator 0 0) remaining))
                   ([(packet-version :: bits 3)
                     (type-id :: bits 3)
                     (= 1 :: bits 1)
                     (subpacket-count :: bits 11)
                     (remaining :: binary)]
                    (list (packet packet-version type-id 'type-1-operator 0 0) remaining))))

(identify-next-packet (BITS->bitstring "D2FE28"))

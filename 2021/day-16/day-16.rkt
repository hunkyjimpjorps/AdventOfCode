#lang racket
(require "../../jj-aoc.rkt"
         bitsyntax
         threading)

(struct packet (version type type-id contents len)
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

(define (get-literal-contents bitstr)
  (for/fold ([assembled (bit-string)]
             [remaining bitstr]
             [total-length 6]
             [complete? #f]
             #:result (values (bit-string->integer assembled #t #f)
                              remaining
                              total-length))
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
                       (remaining :: binary)]
                      (values (bit-string-append assembled (integer->bit-string number 4 #t))
                              remaining
                              (+ total-length 5)
                              #t)))))

(define (get-type-0-contents cnt bitstr [acc '()] [len 0])
  (cond
    [(<= cnt 0) (values (reverse acc)
                        bitstr
                        len)]
    [else (define-values (packet remaining)
            (identify-next-packet bitstr))
          (get-type-0-contents (- cnt (packet-len packet))
                               remaining
                               (cons packet acc)
                               (+ len (packet-len packet)))]))

(define (get-type-1-contents cnt bitstr [acc '()] [len 0])
  (cond
    [(= cnt 0) (values (reverse acc)
                       bitstr
                       len)]
    [else (define-values (packet remaining)
            (identify-next-packet bitstr))
          (get-type-1-contents (sub1 cnt)
                               remaining
                               (cons packet acc)
                               (+ len (packet-len packet)))]))

(define (identify-next-packet bitstr)
  (bit-string-case bitstr
                   ([(packet-version :: bits 3)
                     (= 4 :: bits 3)
                     (remaining :: binary)]
                    (define-values (n now-remaining len)
                      (get-literal-contents remaining))
                    (values (packet packet-version 'literal 4 n len)
                            now-remaining))

                   ([(packet-version :: bits 3)
                     (type-id :: bits 3)
                     (= 0 :: bits 1)
                     (subpacket-length :: bits 15)
                     (remaining :: binary)]
                    (define-values (contents now-remaining sublength)
                      (get-type-0-contents subpacket-length remaining))
                    (values (packet packet-version 'operator type-id contents (+ 22 sublength))
                            now-remaining))

                   ([(packet-version :: bits 3)
                     (type-id :: bits 3)
                     (= 1 :: bits 1)
                     (subpacket-count :: bits 11)
                     (remaining :: binary)]
                    (define-values (contents now-remaining sublength)
                      (get-type-1-contents subpacket-count remaining))
                    (values (packet packet-version 'operator type-id contents (+ 22 sublength))
                            now-remaining))))

(match-define-values (outer-packet n)
  (identify-next-packet data))

;; part 1
(define (packet-sum-version p)
  (match p
    [(packet v 'literal _type-id _contents _len) v]
    [(packet v 'operator _type-id ps _len)
     (foldl (λ (p acc) (+ acc (packet-sum-version p))) v ps)]))

(packet-sum-version outer-packet)

;; part 2
(define packet-f
  (match-lambda
    [0 +]
    [1 *]
    [2 min]
    [3 max]
    [5 (λ (a b) (if (> a b) 1 0))]
    [6 (λ (a b) (if (< a b) 1 0))]
    [7 (λ (a b) (if (= a b) 1 0))]))

(define packet-eval
  (match-lambda
    [(packet _v 'literal _type-id n _len) n]
    [(packet _v 'operator type-id ps _len)
     (~>> ps
          (map packet-eval)
          (apply (packet-f type-id)))]))

(packet-eval outer-packet)


#lang racket

(require advent-of-code
         threading
         memo)

(struct condition (template spring-set))

(define conditions
  (for/list ([line (in-lines (open-aoc-input (find-session) 2023 12 #:cache #true))])
    (match (string-split line #px"[ ,]")
      [(list* template spring-set)
       (condition (string->list template) (map string->number spring-set))])))

(define/memoize
 (do-count template spring-group left-in-group need-gap?)
 ;; template: list of spring positions
 ;; spring-group: list of remaining contiguous groups of damaged springs
 ;; left-in-group: springs remaining in current spring group being placed
 ;; need-gap?: did we just finish placing a spring group
 ;;            and need at least one undamaged spring before starting the next one?
 (match (list template spring-group left-in-group need-gap?)
   ;; no gears left to place, this is an OK arrangement, count it
   [(list '() '() 0 _) 1]
   ;; ambiguous wildcard, try both skipping this spot and starting a gear group here
   [(list (list* #\? t-rest) (list* g g-rest) 0 #f)
    (+ (do-count t-rest g-rest (sub1 g) (= g 1)) (do-count t-rest spring-group 0 #f))]
   ;; definitely a place for a good spring (.); move on without consuming any spring groups
   [(or (list (list* #\? t-rest) '() 0 #f)
        (list (list* #\? t-rest) _ 0 #t)
        (list (list* #\. t-rest) _ 0 _))
    (do-count t-rest spring-group 0 #f)]
   ;; definitely a place for a damaged spring (#); use the next spring group and remove 1 from it
   [(list (list* #\# t-rest) (list* g g-rest) 0 #f) (do-count t-rest g-rest (sub1 g) (= g 1))]
   [(list (list* (or #\? #\#) t-rest) g left #f) (do-count t-rest g (sub1 left) (= left 1))]
   ;; if nothing above works, this arrangement's invalid
   [_ 0]))

(define (count-solutions c)
  (match-define (condition template spring-set) c)
  (do-count template spring-set 0 #f))

;; part 1
(for/sum ([c (in-list conditions)]) (count-solutions c))

;; part 2
(define expanded-conditions
  (for/list ([c (in-list conditions)])
    (condition (~> c condition-template (make-list 5 _) (add-between #\?) flatten)
               (~> c condition-spring-set (make-list 5 _) flatten))))

(for/sum ([c* (in-list expanded-conditions)]) (count-solutions c*))

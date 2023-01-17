#lang racket

(define/contract (intersection nums1 nums2)
  (-> (listof exact-integer?) (listof exact-integer?) (listof exact-integer?))
  (set-intersect nums1 nums2))
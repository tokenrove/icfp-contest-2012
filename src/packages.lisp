
(defpackage :model
  (:use #:cl #:anaphora #:alexandria))

(defpackage :bitplane
  (:use #:cl #:fiveam)
  (:export #:make-plane #:point? #:population-count))

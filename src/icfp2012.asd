(asdf:defsystem #:icfp2012
  :serial t
  :depends-on (#:fiveam #:anaphora #:alexandria)
  :components ((:file "packages")
               (:file "bitplane")
               #+(or)(:file "model")))

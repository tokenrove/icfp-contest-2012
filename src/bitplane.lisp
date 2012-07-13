
(in-package :bitplane)

;; bitplane behavior:
;; - test point
;; - set point
;; - shift left, right, up, down

(defstruct (plane (:conc-name) (:constructor %make-plane))
  (width -1 :type fixnum)
  (height -1 :type fixnum)
  (bits 0 :type integer)
  (mask 0 :type integer :read-only t))

(defun make-plane (w h &key (bits 0))
  (%make-plane :width w :height h :bits bits :mask (ldb (byte (* w h) 0) -1)))

(defun visualize (p)
  (dotimes (y (width p))
    (dotimes (x (width p))
      (format t "~C" (if (point? p x y) #\. #\ )))
    (format t "~%")))

(defun point-offset (p x y) (+ x (* (width p) y)))
(defun (setf point?) (v p x y)
  (setf (ldb (byte 1 (point-offset p x y)) (bits p)) (if v 1 0)))
(defun point? (p x y)
  (plusp (ldb (byte 1 (point-offset p x y)) (bits p))))
(defun population-count (p) (logcount (bits p)))


(defun shift (p dir)
  (make-plane (width p) (height p)
              :bits (logand
                     (ash (bits p)
                          (ecase dir
                            ((left) -1) ((right) 1) ((up) (- (width p)))
                            ((down) (width p))))
                     (mask p))))

(test basic-1
  (let ((p (make-plane 5 5)))
    (setf (point? p 2 2) t)
    (is-true (point? p 2 2))
    (is-false (point? p 3 4))))

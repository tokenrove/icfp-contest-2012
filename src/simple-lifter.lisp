;;;
;; After finally admitting defeat late on the Sunday night of the ICFP
;; competition, I started hacking up a simple lifter to demonstrate
;; some of the ideas I had.

(in-package :simple-lifter)

(defclass model ()
  ((map :accessor map-of)
   (growth :initform 0)
   (razors :initform 0)
   (water :initform 0)
   (flooding :initform 0)
   (waterproof :initform 10)
   (trampolines :accessor trampolines-of :initform (make-array 9))
   (max-lambdas :accessor max-lambdas-of :initform 0)
   (robot-position :accessor robot-position-of)
   (lift-position :accessor lift-position-of)))

(defclass state ()
  ((model)
   (map)
   (n-moves :initform 0)
   (n-lambdas :initform 0)
   (saturation :initform 0)
   (n-razors :initform 0)))

(defmethod print-object ((o model) out)
  (with-slots (map) o
    (dotimes (y (array-dimension map 0)) (dotimes (x (array-dimension map 1)) (princ (aref map y x) out)) (terpri out))
    (loop for s in '(growth razors water flooding waterproof trampolines max-lambdas)
          do (format out "~A: ~A~&" s (slot-value o s)))))

(defun point (x y) (complex x y))

(defun read-map (in)
  (let* ((lines
          (loop for l = (read-line in nil 'eof)
                while (and (not (eq l 'eof)) (some #'(lambda (x) (char/= x #\Space #\Tab #\Newline)) l))
                collect l))
         (w (loop for l in lines maximize (length l)))
         (h (length lines))
         (m (make-instance 'model)))
    (setf (map-of m) (make-array (list h w) :element-type 'character))
    (loop with map = (map-of m)
          for y below h
          for l in (reverse lines)
          do (dotimes (x w)
               (let ((c (if (< x (length l)) (schar l x) #\#)))
                 (setf (aref map y x) c)
                 (case c (#\\ (incf (max-lambdas-of m)))
                       (#\R (setf (robot-start-position-of m) (point x y)))
                       (#\L (setf (lift-position-of m) (point x y)))))))
    (loop for s = (read in nil 'eof)
          while (not (eq s 'eof))
          do (progn
               (case s
                 ((growth razors water flooding waterproof)
                  (setf (slot-value m s) (read in)))
                 ((trampoline)
                  (let (jump target)
                    (setf jump (read in))
                    (assert (eq 'targets (read in)))
                    (setf target (read in))
                    (setf (aref (trampolines-of m)
                                (position jump '(A B C D E F G H I))) target)))
                 (t (format *error-output* "Bad metadata: not sure what to do with ~A~&" s)))))
      m))


(defun connected-portions (model)
  ;; start from robot-position-of model
  )

(defun evaluate-position (state move)
  (let ((new-state state))
    (values 'abort new-state)))

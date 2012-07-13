;;;; model -- the world model
;;
;; Basically the same way we'd work with cellular automata; functional
;; updates, concrete rules that can be applied in parallel.

(in-package :model)

(defparameter *tiles*
  '((#\  . EMPTY) (#\# . WALL) (#\* . ROCK) (#\. . EARTH) (#\L . CLOSED-LIFT) (#\O . OPEN-LIFT) (#\R . ROBOT) (#\\ . LAMBDA))
  "Sorted array mapping a char to a tile type.")

(defstruct (model (:constructor %make-model))
  width height
  wall-plane
  earth-plane
  rock-plane
  lambda-plane
  robot
  lift)
(defvar *planes* '(wall-plane earth-plane rock-plane lambda-plane))
(defmacro make-plane-accessors (&rest ps)
  `(progn
     ,@(loop for p in ps
            collect `(defmacro ,(symbolicate p '?) (v pt)
                       (list 'bitplane:point? (list ',(symbolicate 'model- p '-plane) v) `(realpart ,pt) `(imagpart ,pt))))))
(make-plane-accessors wall earth rock lambda)

(defmacro make-model (width height)
  (once-only (width height)
    `(%make-model :width ,width :height ,height
                  ,@(loop for p in '(wall-plane earth-plane rock-plane lambda-plane)
                          nconc `(,(make-keyword p) (bitplane:make-plane ,width ,height))))))

(defun point (x y) (complex x y))

#+(or)(defmacro map-model ((model x y) &body body))

(defun model<-map (map-fd)
  (let* ((lines
          (loop for l = (read-line map-fd nil 'eof)
                while (not (eq l 'eof))
                collect l))
         (m (make-model (loop for l in lines maximize (length l)) (length lines))))
    (prog1 m
      (loop for l in lines
            for y from (1- (model-height m)) downto 0
            do (loop for c across l
                     for tile = (cdr (assoc c *tiles*))
                     for x from 0
                     for p = (point x y)
                     do (ecase tile
                          ((wall) (setf (wall? m p) t))
                          ((earth) (setf (earth? m p) t))
                          ((rock) (setf (rock? m p) t))
                          ((lambda) (setf (lambda? m p) t))
                          ((empty))
                          ((closed-lift) (setf (model-lift m) p))
                          ((robot) (setf (model-robot m) p))
                          ((open-lift) (error "~A not allowed in map defn" tile))))))))

(defun empty? (m p)
  (not (or (wall? m p) (rock? m p) (earth? m p) (lambda? m p) (= p (model-robot m)) (= p (model-lift m)))))
(defun empty! (m p &key (lambda-pickup? nil))
  (assert (not (or (wall? m p) (and lambda-pickup? (lambda? m p)) (= p (model-robot m)) (= p (model-lift m)))))
  (setf (rock? m p) nil)
  (setf (earth? m p) nil)
  (when lambda-pickup? (setf (lambda? m p) nil)))

(defun empty-plane (m)
  (bitplane:make-plane (model-width m) (model-height m)
                       :bits (lognot
                              (logior (bitplane::bits (model-wall-plane m))
                                      (bitplane::bits (model-rock-plane m))
                                      (bitplane::bits (model-lambda-plane m))
                                      (ash 1 (offset<-point (model-robot m) (model-width m)))
                                      (ash 1 (offset<-point (model-lift m) (model-width m)))))))

(defun offset<-point (p w) (+ (realpart p) (* (imagpart p) w)))

(defun visualize (m)
  (loop for y from (model-height m) downto 0
        do (progn
             (loop for x from 0 below (model-width m)
                   do (let ((p (point x y)))
                        (format t "~C" (cond
                                         ((= (model-robot m) p) #\R)
                                         ((= (model-lift m) p) (if (= 0 (lambdas-left m)) #\O #\L))
                                         ((wall? m p) #\#)
                                         ((earth? m p) #\.)
                                         ((rock? m p) #\*)
                                         ((lambda? m p) #\λ)
                                         ((empty? m p) #\ )
                                         (t (error "Bad map!"))))))
             (format t "~%"))))

#+(or)(defun update (prior future)
        (move-robot prior future move)
        (update-map prior future))

(defun lambdas-left (m)
  (bitplane:population-count (model-lambda-plane m)))

(defun valid-move? (prior move)
  (ecase move
    ((left right up down)
     (let* ((offset (ecase move (left #C(-1 0)) (right #C(1 0)) (up #C(0 1)) (down #C(0 -1))))
            (new-p (+ (model-robot prior) offset)))
       (or
        (earth? prior new-p)
        (empty? prior new-p)
        (and (case move ((left right) t)) (rock? prior new-p) (empty? prior (+ new-p offset)))
        (and (= 0 (lambdas-left prior)) (= new-p (model-lift prior))))))
    ((wait abort) t)))

#+(or)(defun move-robot (prior future move)
  ;; handle abort and wait
  (if (valid-move? prior move)
      ()                                ; update robot and rocks
      (format *error-output* "Invalid move: ~A" move)))

(defun update-map (prior future)
  (loop for y from (1- (model-height prior)) downto 0
        do (dotimes (x (model-width prior))
             (let* ((p (point x y))
                    (left (+ p #C(-1 0))) (right (+ p #C(1 0))) (below (+ p #C(0 -1))))
               (when (rock? prior p)
                 (cond
                   ((empty? prior below)
                    (empty! future p)
                    (setf (rock? future below) t))
                   ((and (rock? prior below)
                         (empty? prior right)
                         (empty? prior (+ right #C(0 -1))))
                    (empty! future p)
                    (setf (rock? future (+ right #C(0 -1))) t))
                   ((and (rock? prior below)
                         (empty? prior left)
                         (empty? prior (+ left #C(0 -1))))
                    (empty! future p)
                    (setf (rock? future (+ left #C(0 -1))) t))
                   ((and (lambda? prior below)
                         (empty? prior right)
                         (empty? prior (+ right #C(0 -1))))
                    (empty! future p)
                    (setf (rock? future (+ right #C(0 -1))) t)))))))
  future)

;Primitiva def class
(defparameter *classes-specs* (make-hash-table))

(defun add-class-spec (name class-spec)
  (setf (gethash name *classes-specs*) class-spec))

(defun get-class-spec (name)
  (gethash name *classes-specs*))


(defun def-class (class-name parents &rest slot-value)
  (if (null parents)
    ))

;Primitiva New
(defun new (class-name )
  ())

;Primitiva getv
(defun getv (instance slot-name)
  ())

;Primitiva getvx. Slot-name deve essere una lista non vuota
(defun getvx (instance &rest slot-name)
  ())

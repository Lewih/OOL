;Primitiva def class hash table con tutte le definizioni di classi
(defparameter classes (make-hash-table))

;aggiunge classe alla hash table
(defun add-class-spec (name class-spec)
  (setf (gethash name classes) class-spec))

;ritorna la struttura di una classe dato il nome della stessa
(defun get-class-spec (name)
  (gethash name classes))


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

 (defun formatta (slot-value)
	(if (null slot-value) nil
	(append (list (list (first slot-value) (second slot-value))) (formatta (cdr( cdr slot-value))))))

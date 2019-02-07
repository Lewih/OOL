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


;def-class ora funziona
(defun def-class (name parents &rest slot-value)
	(add-class-spec  name (append (list parents) (formatta slot-value))))

;new class not tested
(defun new (class-name &rest param)
	((if (null param) nil
	 (append (new1 (car (get-class-spec class-name)) param) (cdr (get-class-spec class-name))))))
;function that is used to cicle to the superclasses of a class and call the new recurvivly on them
;TODO il problema potrebbe essere che chiamo passando param invece che un elenco di parametri &rest riceve una lista e quindi fa una lista che contiene la lista
; spoiler, si, quello è il problema
(defun new1(superC param)
	(append (new (car superC) param) new1(cdr superC)))

(defparameter *classes-specs* (make-hash-table))
(defun add-class-spec (name class-spec)
  (setf (gethash name *classes-specs*) class-spec))
(defun get-class-spec (name)
  (gethash name *classes-specs*))

;Primitiva definizione classe, TODO per segnalare errore ritornare NIL
(defun def-class (class-name parents &rest slot-value)
  (cond
    ((not (symbolp class-name))
    (error "Error: nome classe non e' un simbolo"))
    
    ((not (listp parents))
    (error "Error: parent non e' una lista"))
    
    ((parents-control class-name parents)
     (error "Error: classe e parents con stesso nome")
     )
    ((values-control (formatta slot-value))
     (error "Error: bad values formatting")))
  
  (let*
      ((genitori
	(if (null parents)
	    '(orfano)
	    parents)))
    (remhash class-name *classes-specs*) ;rimuovo classe se presente
    (add-class-spec class-name (list genitori  (formatta slot-value))))
  ;ritorno class-name da specifica
  ;class-name
  )

;Primitiva New 
(defun new (class-name &rest parameters)
  (if (values-control (formatta parameters))
      (error "Error: bad format"))
  
  (if (and (get-class-spec class-name)
	   (instance-check (first get-class-spec class-name) (formatta parameters)))
      ('oolist class-name (formatta parameters));TODO da quotare?
      NIL))

;Primitiva getv
(defun getv (instance slot-name)
  (let* ((is-in-instance (recursive-getv-instance (rest (rest instance)) slot-name)))
    
    (if (is-in-instance)
	is-in-instance
        (recursive-getv-tree (append (second instance) (first (get-class-spec class))) slot-name))))

(defun recursive-getv-instance (values slot-name)
  (if (equals values NIL)
      NIL ;base
      (or ;passo
       (and (equals (first (first values)))
	    (not (equals (second (first values) '=>))))) ;TODO controllare futura codifica metodi
      (recursive-getv-instance (rest values) slot-name)
      ))

(defun recursive-getv-tree (classes slot-name)
  ())

;Primitiva getvx. Slot-name deve essere una lista non vuota
(defun getvx (instance &rest slot-name)
  ())



(defun formatta (slot-value)
	(if (null slot-value) nil
	(append (list (list (first slot-value) (second slot-value))) (formatta (cdr( cdr slot-value))))))

;controllo che first sia simbolo in slot-value
(defun values-control (values)
  (if (equal values NIL)
      NIL
      (or (not(symbolp (first (first values))))
	  (values-control (rest values)))))

;controllo che parents non contenga il nome di classe
(defun parents-control (class-name parents)
  (if (equal parents NIL)
      NIL
      (or (equal (first parents) class-name)
	  (parents-control class-name (rest parents)))))

(defun instance-check (class parameters)
  (if (equal parameters NIL)
      T
      (and (getv (list 'oolist class NIL) (first(first parameters))) ;TODO parametro potrebbe avere NIL come valore
	   instance-check (class (rest parameters)))))


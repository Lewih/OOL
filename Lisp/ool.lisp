;;;; Pugno Michele 830513
;;;; Piovani Davide

;Definizione e manipolazione Hash-Table
(defparameter *classes-specs* (make-hash-table))
(defun add-class-spec (name class-spec)
  (setf (gethash name *classes-specs*) class-spec))
(defun get-class-spec (name)
  (gethash name *classes-specs*))

;Funzione formattazione per lista associativa
(defun formatta (slot-value)
  (if (null slot-value)
      nil
      (append (list (list (first slot-value) (second slot-value)))
	      (formatta (cdr( cdr slot-value))))))

;Primitiva definizione classe
(defun def-class (class-name parents &rest slot-value)
  (cond
    ((not (symbolp class-name))
     (error "Error: nome classe non e' un simbolo"))
    ((not (listp parents))
     (error "Error: parent non e' una lista"))
    ((parents-control class-name parents)
     (error "Error: classe e parents con stesso nome"))
    ((values-control (formatta slot-value))
     (error "Error: bad values formatting")))
  (let*
      ((genitori
	(if (null parents)
	    NIL
	    (remove-duplicates parents)))
       (formatted-slot (identify-method (formatta slot-value) nil)))
    (remhash class-name *classes-specs*)
    (add-class-spec class-name (list genitori formatted-slot)))
  class-name)

;controllo che first sia simbolo in slot-value formattata
(defun values-control (values)
  (if (equal values NIL)
      NIL
      (or (not(symbolp (first (first values))))
	  (values-control (rest values)))))

;Controllo esistenza parents e omonimia con class-name
(defun parents-control (class-name parents)
  (cond
    ((equal parents NIL)
     NIL)
    ((not (get-class-spec (first parents)))
     (error "Errore: classe genitore non esistente"))
    ((or (equal (first parents) class-name)
	 (parents-control class-name (rest parents))))))

;Identifico i metodi e li tratto
(defun identify-method (values result)
  (cond
    ((null values)
     result)
    ((and (listp (second (first values)))
	  (equal (first (second (first values))) '=>))
     (identify-method
      (rest values)
      (append result (list (list
			    (first (first values))
			    (process-method
			     (first (first values))
			     (second (first values))))))))
    ((not (null values))
     (identify-method (rest values)
		      (append result
			      (list (first values)))))))

;Primitiva New 
(defun new (class-name &rest parameters)
  (if (values-control (formatta parameters))
      (error "Error: bad format"))
  (if (and (get-class-spec class-name)
	   (instance-check class-name (formatta parameters)))
      (list 'oolinst class-name (formatta parameters))
      (error "Errore: classe o parametro non esistente")))

;Controllo esistenza dei valori di New
(defun instance-check (class parameters)
  (if (equal parameters NIL)
      T
      (and (getv (list 'oolinst class NIL) (first(first parameters)))
	   (instance-check class (rest parameters)))))

;Primitiva getv
(defun getv (instance slot-name)
  (cond
    ((or (not (symbolp slot-name))
	 (null slot-name))
     (error "Errore: slot-name non valido"))
    ((not (equal 'oolinst (first instance)))
     (error "Errore: istanza non valida")))
  
  (let* ((is-in-instance
	  (recursive-getv-instance (third instance) slot-name)))
    (if is-in-instance
	(second is-in-instance)
	(let* ((is-in-tree
		(recursive-getv-tree (list (second instance)) slot-name)))
	  (if is-in-tree
	      (second is-in-tree)
	      (error "Errore: valore non valido"))))))

;Ritorna una coppia
(defun recursive-getv-instance (values slot-name)
  (cond
    ((equal values NIL)
     NIL)
    ((equal (first (first values)) slot-name)
     (first values))
    ((not (equal (first (first values)) slot-name))
     (recursive-getv-instance (rest values) slot-name))))

;Ritorna una coppia
(defun recursive-getv-tree (classes slot-name)
  (let* ((is-in-level
	  (recursive-getv-instance (second (get-class-spec (first classes)))
				   slot-name)))
    (cond
      ((equal classes  NIL)
       NIL)
      (is-in-level
       is-in-level)
      ((not is-in-level)
       (recursive-getv-tree (append (first (get-class-spec (first classes)))
				    (rest classes))
			    slot-name)))))

;Primitiva getvx
(defun getvx (instance &rest slot-name)
  (if (null slot-name)
      (error "Errore: slot-name vuoto"))
  (getvx-recursive instance slot-name))

;Effettiva getvx
(defun getvx-recursive (instance slot-name)
  (cond
    ((not (symbolp (first slot-name)))
     (error "Errore: slot-names devono essere simboli"))
    ((null (rest slot-name))
     (getv instance (first slot-name)))
    ((rest slot-name)
     (getvx-recursive (getv instance (first slot-name))
		      (rest slot-name)))))

;Riscrivo S-expression cosi da poter usare this
(defun rewrite-method-code (method-name method-spec)
  (if (symbolp method-name)
      (append
       (list 'lambda)
       (list(append (list 'this) (second method-spec)))
       (list (append '(progn) (rest (rest method-spec)))))))

;Funzione principale gestione metodi
(defun process-method (method-name method-spec)
  (setf (fdefinition method-name)
	(lambda (this &rest args)
	  (apply (getv this method-name)
		 (append (list this) args))))
  (eval (rewrite-method-code method-name method-spec)))

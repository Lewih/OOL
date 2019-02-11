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
     (error "Error: classe e parents con stesso nome"))
    
    ((values-control (formatta slot-value))
     (error "Error: bad values formatting")))
  
  (let*
      ((genitori
	(if (null parents)
	    NIL
	    parents)))
    (remhash class-name *classes-specs*) ;rimuovo classe se presente
    (add-class-spec class-name (list genitori (formatta slot-value))))
  ;ritorno class-name da specifica
  class-name)

;controllo che first sia simbolo in slot-value formattata
(defun values-control (values)
  (if (equal values NIL)
      NIL
      (or (not(symbolp (first (first values))))
	  (values-control (rest values)))))

;controllo esistenza parents e omonimia con class-name
(defun parents-control (class-name parents)
  (cond
    ((equal parents NIL)
     NIL)	

    ((not (get-class-spec (first parents)))
     (error "Errore: classe genitore non esistente"))
	
    ((or (equal (first parents) class-name)
	 (parents-control class-name (rest parents))))))

;Primitiva New 
(defun new (class-name &rest parameters)
  (if (values-control (formatta parameters))
      (error "Error: bad format"))
  
  (if (and (get-class-spec class-name)
	   (instance-check class-name (formatta parameters)))
      (list 'oolinst class-name (formatta parameters))
      (error "Errore: classe o parametro non esistente")))

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

(defun recursive-getv-instance (values slot-name);ritorna una coppia ;FINISHED
  (cond
    ((equal values NIL)
     NIL);base
    
    ((and (equal (first (first values)) slot-name)
	  (not (equal (second (first values)) '=>)))
     (first values)) ;TODO controllare futura codifica metodi TODO
    
    ((not (equal (first (first values)) slot-name))
     (recursive-getv-instance (rest values) slot-name)))) ;passo

(defun recursive-getv-tree (classes slot-name) ; ritorna una coppia ;FINISHED
  (let* ((is-in-level
	  (recursive-getv-instance (second (get-class-spec (first slot-name)))
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

(defun getvx-recursive (instance slot-name)
  (cond
    ((not (symbolp (first slot-name)))
     (error "Errore: slot-names devono essere simboli"))
    
    ((null (rest slot-name))
     (getv instance (first slot-name)))

    ((rest slot-name)
     (getvx-recursive (getv instance (first slot-name)) (rest slot-name)))))

;funzione formattazione tuple
(defun formatta (slot-value)
  (if (null slot-value)
      nil
      (append (list (list (first slot-value) (second slot-value)))
	      (formatta (cdr( cdr slot-value))))))

;funzione che dato un nome di una funzione e il suo corpo la definisce a tempo di esecuzione e ci aggiunge il parametro this
;la funzione (nel senso di scopo) del parametro this è la seguente, al parametro this si passa come valore l'oggetto su cui si vuole
;chiamare il metodo, e nella funzione i riferimenti a this passeranno al oggetto passato, di conseguenza ogni funzione oltre ai suoi parametri
;avrà un parametro this messo appositamente per effettuare il collegamento tra l'utilizzo di this stesso e l'effettivo oggetto
;piccola e potente, come il mio.. no aspet volevo dire come il mio google home mini! adoro il mio google home mini...
(defun def-unction (name function) 
  (compile (eval (append (list 'defun) (list name) (append (list (append (list 'this) (car function)))
							   (cdr function))))))

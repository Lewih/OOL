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

<<<<<<< HEAD
=======
;new class not tested
;(defun new (class-name &rest param)
;	((if (null param) nil
;	 (append (new1 (car (get-class-spec class-name)) param) (cdr (get-class-spec class-name))))))
;function that is used to cicle to the superclasses of a class and call the new recurvivly on them
;TODO il problema potrebbe essere che chiamo passando param invece che un elenco di parametri &rest riceve una lista e quindi fa una lista che contiene la lista
; spoiler, si, quello è il problema
;(defun new1(superC param)
;	(append (new (car superC) param) new1(cdr superC)))

;funzione che dato un nome di una funzione e il suo corpo la definisce a tempo di esecuzione e ci aggiunge il parametro this
;la funzione (nel senso di scopo) del parametro this è la seguente, al parametro this si passa come valore l'oggetto su cui si vuole
;chiamare il metodo, e nella funzione i riferimenti a this passeranno al oggetto passato, di conseguenza ogni funzione oltre ai suoi parametri
;avrà un parametro this messo appositamente per effettuare il collegamento tra l'utilizzo di this stesso e l'effettivo oggetto
;piccola e potente, come il mio.. no aspet volevo dire come il mio google home mini! adoro il mio google home mini...
(defun def-unction (name function) 
	(compile (eval (append (list 'defun) (list name) (append (list (append (list 'this) (car function))) (cdr function))))))
>>>>>>> 8c27a538833e7b2b09bd152b5ba1fbcf5a959c7c

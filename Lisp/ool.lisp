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
    (add-class-spec class-name (list genitori  (formatta slot-value))))
  ;ritorno class-name da specifica
  ;class-name
  )

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
      (and (getv (list 'oolinst class NIL) (first(first parameters))) ;TODO parametro potrebbe avere NIL, chiamo errore
	   (instance-check class (rest parameters)))))

;Primitiva getv
(defun getv (instance slot-name)
  (if (not slot-name)
      (error "Errore: inserire un parametro"))
  (if (not (equal 'oolinst (first instance)))
      (error "Errore: istanza non valida"))
  
  (let* ((is-in-instance (recursive-getv-instance (third instance) slot-name))) ; corretto errore
    (if is-in-instance
	(second is-in-instance)
	(let* ((is-in-tree (recursive-getv-tree2 (list (second instance)) slot-name))); uso tree2
	  (if is-in-tree
	      (second is-in-tree)
	      (error "Errore: valore non valido"))))))

(defun recursive-getv-instance (values slot-name);ritorna una coppia ;FINISHED
  (cond
    ((equal values NIL)
     NIL);base
    
    ((and (equal (first (first values)) slot-name)
	  (not (equal (second (first values)) '=>)))
     (first values)) ;TODO controllare futura codifica metodi
    
    ((not (equal (first (first values)) slot-name))
     (recursive-getv-instance (rest values) slot-name)))) ;passo

(defun recursive-getv-tree (classes slot-name) ; ritorna una coppia, non in uso
  (let* ((is-in-level (recursive-getv-instance (build-values-list classes) slot-name) ))
    (cond
      ((equal classes  NIL)
       NIL)
      
      (is-in-level
       is-in-level)
      
      ((not is-in-level)
       (recursive-getv-tree (build-superclasses-list classes) slot-name)))))

(defun recursive-getv-tree2 (classes slot-name) ; ritorna una coppia, uso questa
  (let* ((is-in-level (recursive-getv-instance (build-values-list classes) slot-name) ))
    (cond
      ((equal classes  NIL)
       NIL)
      
      (is-in-level
       is-in-level)
      
      ((not is-in-level)
       (recursive-getv-tree2 (build-superclasses-list classes) slot-name)))))

(defun build-values-list (classes)
  (if (equal classes NIL)
      NIL
      (append (second (get-class-spec (first classes))) (build-values-list (rest classes)))))

(defun build-superclasses-list (classes)
  (if (equal classes NIL)
      NIL
      (append (first (get-class-spec (first classes))) (build-superclasses-list (rest classes)))))

;Primitiva getvx. Slot-name deve essere una lista non vuota. divisione in 2 metodi per 2 motivi 
;-primo il controllo che slot-name sia ugugale a nil non deve interferire con lo stesso controllo fatto nella ricorsione
;-secondo  perchè altrimenti no va prorpio, &rest e ricorsione non vanno daccordo come ti avevo detto
(defun getvx (instance &rest slot-name) (if (null slot-name)
                                            (error "Error: non sono stati passati slot-name")
                                            (getvx1 instance slot-name)))

(defun getvx1 (instance slot-name)  (if (null slot-name)
                                        instance
                                        (getv (getvx instance (butlast slot-name)) (last slot-name))))

;funzione formattazione tuple
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
  (cond ((equal parents NIL)
	 NIL)
	
	((not (get-class-spec (first parents)))
	 (error "Errore: classe genitore non esistente")) ;controllo che esistano i genitori
	
	((or (equal (first parents) class-name)
	  (parents-control class-name (rest parents)))))) ;controllo uguaglianza 

;new class not tested
;(defun new (class-name &rest param)
;	((if (null param) nil
;	 (append (new1 (car (get-class-spec class-name)) param) (cdr (get-class-spec class-name))))))
;function that is used to cicle to the superclasses of a class and call the new recurvivly on them
;TODO il problema potrebbe essere che chiamo passando param invece che un elenco di parametri &rest riceve una lista e quindi fa una lista che contiene la lista
; spoiler, si, quello è il problema
;(defun new1(superC param)
;	(append (new (car superC) param) new1(cdr superC)))
;
;funzione che dato un nome di una funzione e il suo corpo la definisce a tempo di esecuzione e ci aggiunge il parametro this
;la funzione (nel senso di scopo) del parametro this è la seguente, al parametro this si passa come valore l'oggetto su cui si vuole
;chiamare il metodo, e nella funzione i riferimenti a this passeranno al oggetto passato, di conseguenza ogni funzione oltre ai suoi parametri
;avrà un parametro this messo appositamente per effettuare il collegamento tra l'utilizzo di this stesso e l'effettivo oggetto
;piccola e potente, come il mio.. no aspet volevo dire come il mio google home mini! adoro il mio google home mini...
(defun def-unction (name function) 
  (compile (eval (append (list 'defun) (list name) (append (list (append (list 'this) (car function)))
							   (cdr function))))))

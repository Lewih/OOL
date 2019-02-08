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

;funzione che dato un nome di una funzione e il suo corpo la definisce a tempo di esecuzione e ci aggiunge il parametro this
;la funzione (nel senso di scopo) del parametro this è la seguente, al parametro this si passa come valore l'oggetto su cui si vuole
;chiamare il metodo, e nella funzione i riferimenti a this passeranno al oggetto passato, di conseguenza ogni funzione oltre ai suoi parametri
;avrà un parametro this messo appositamente per effettuare il collegamento tra l'utilizzo di this stesso e l'effettivo oggetto
;piccola e potente, come il mio.. no aspet volevo dire come il mio google home mini! adoro il mio google home mini...
(defun def-unction (name function) 
	(compile (eval (append (list 'defun) (list name) (append (list (append (list 'this) (car function))) (cdr function))))))

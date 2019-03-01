Pugno Michele 830513
Piovani Davide 830113

OOL

Implementazione delle primitive

1) '(' def-class <class-name>, <parents>, <slot-values>* ')' :

    Prende in input il nome della classe, i parents della classe e
    una lista di slot value come da specifica.
    Definisce la classe inserendola nella hash table con i relativi parametri
    e metodi valutati.
    Slot-values sono salvati nella hash table come
    lista associativa nella forma:
    
	((<Nome> <Valore) (<Nome1> <Valore1>) ... )

    Le classi possono essere ridefinite, la gestione delle istanze
    della classe deprecata viene lasciata all'utente.


2) '(' new <class-name>, [<slot-name>, <value>]* ')' :

    Ritorna una nuova istanza della classe nella forma:
    
    	'(oolinst <class-name> <valori>)
    
    Questa lista sarà poi associata ad un simbolo con l'ausilio
    del built-in "defparameter".
    
    <valori> è una lista associativa nella forma:
    
    	((<Nome> <Valore) (<Nome1> <Valore1>) ... )


3) '(' getv <instance> <slot-name> ')' :

    Ritorna il valore associato allo slot-name passato relativo
    all'istanza passata, se nell'istanza non è presente il valore
    allora la ricerca si estende alle superclassi come da specifica.

4) '(' getvx <instance> <slot-name>+ ')' :

    Richiama ricosivamente getv per ottenere il comportamento
    richiesto in specifica.

In tutte le funzioni vengono effettuati controlli
circa la consistenza degli argomenti come da specifica.


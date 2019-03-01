Pugno Michele 830513
Piovani Davide 830113

OOP

Implementazione delle primitive

1) def-class(<class-name>, <parents>, <slot-values>)

    Prende in input un nome-classe, una lista di parents e una lista di slot,
    asserisce un termine in questa forma (ove slots è una lista):
    
    	    class(nome-classe, parents, slots)

    Nel caso in cui la classe sia già stata definita in precedenza essa
    viene ridefinita al costo di perdere tutte le istanze e i metodi
    ad esse associati che siano influenzati o possibilmente
    influenzati dal cambiamento.
    Ciò serve a mantenere la base di conoscenza di Prolog in uno stato
    coerente, mentre la possibilità di ridefinire una classe mantiene
    l'ambiente prolog dinamico e interattivo per l'utente.

2) new(<instance-name>, <class-name>, <slot-values>)

    Riceve in input il nome dell'istanza, il nome della classe dell'istanza
    e una lista di elementi come da specifica.
    E' presente anche un predicato semplificato new/2. 
    Asserisce un termine in questa forma (ove values è una lista):
    
    	      instance(nomeIstanza, nomeClasse, values)
	      
    Inoltre asserisce tutti i metodi definiti nell'istanza oppure
    se non specificati, i metodi ereditati.
    
    Nel caso in cui si stia ridefinendo un'istanza tutti i metodi associati
    all'istanza omonima precedente vengono rimossi dalla base di conoscenza,
    successivamente si rimuove l'istanza stessa per procede ad asserire
    i nuovi valori e metodi.

3) getv(<instance>, <slot-names>, <result>)

    Estrae il valore di un campo da un'istanza, cercando prima se è stato
    ridefinito nel'istanza stessa e successivamente, se non trovato,
    scorrendo le superclassi.
    Il predicato in questione restituisce solo il primo risultato scorrendo
    la gerarchia come da specifica Lisp.
    
    E' inoltre presente un predicato identico get_all/3 con la differenza
    che questo, in concomitanza con l'operatore ";" in ambiente interattivo,
    restituisce tutti i possibili risultati della query.


4) getvx(<instance>, <slot-names>, <result>)

    Richiama ricosivamente getv per prendere un valore da classi contenute
    in altre classi come da specifica, da errore nel caso uno dei parametri
    su cui deve effettuare la get risulti un metodoo o non risulti una classe.


In tutti i predicati vengono effettuati controlli
circa la consistenza degli argomenti come da specifica.

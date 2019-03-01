Pugno Michele 830513
Piovani Davide 830113


def-class: prende in input il nome della classe, i parents della classe e
una lista di slot value definiti come da specifica.
Definisce la classe inserendola nella hash table delle classi,con i relativi
parametri e valori di default e preparando già i metodi per essere chiamati 
dinamicamente, se una classe viene ridefinita essa viene sostituita,
le istanze di quella classe non saranno in uno stato consistente nel caso
vengano rimossi attributi che erano stati ridefiniti nell'istanza.


new: ritorna una nuova istanza della classe passata, è possibile ridefinire
parametri e metodi delle classi, non è possibile definirne di nuovi specifici
dell'oggetto che non siano presenti nella classe. nel caso di un duplicato 
dello stesso oggetto quello precedente viene sovrascritto.

getv: ritorna il valore associato allo slot-name passato e relativo
all'istanza passata, se nell'istanza non è stato ridefinito il valore
o il metodo passato allora viene cercato percorrendo una catena di attributi.
usa recursive-getv-instance per cercare nell'istanza, e recursive-getv-tree
per cercare nelle superclassi.

getvx: richiama ricosivamente getv per prendere un valore da classi contenute
in altre classi come da specifica.

identify-method: funzione tail-recursive che scorre una lista dei
parametri/metodi di una classe/oggetto ed esegue la process-method sui metodi,
predisponendoli per essere chiamati.


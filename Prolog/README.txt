# ProgettoLP
Pugno Michele 830513
Piovani Davide 830113

def-class: prende in input un nome-classe, una lista di parents, e una lista
di slot, aggiunge object alla lista dei parents e ne rimuove i duplicati
asserisce un termine class(nome-classe, parents, slots), in caso di classe
già definita in precedenza essa viene ridefinita.

new: riceve in input il nome dell'istanza, il nome della classe dell'istanza
e una lista di elementi con questa struttura <slot-name> ’=’ <value>.
Asserisce un termine instance(nomeIstanza, nomeClasse, values), e ne asserisce
anche tutti i metodi, se una certa istanza vien ridefinita si va a cancellare
quella vecchia sostituendola, e sostituendone anche i vari metodi.

getv: estrae il valore di un campo da un'istanza, cercando prima se è stato
ridefinito nel'istanza stessa, e se non viene trovato così si va a cercarlo 
scorrendo le superclassi.


getvx: richiama ricosivamente getv per prendere un valore da classi contenute
in altre classi come da specifica, da errore nel caso uno dei parametri su cui
deve effettuare la get risulti un metodoo o non risulti una classe.

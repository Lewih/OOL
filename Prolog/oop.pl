%%%% Pugno Michele 830513
%%%% Piovani Davide 830113

%Definisco procedure dinamiche
:- dynamic instance/3.
:- dynamic class/3.

%Primitiva def_class
def_class(Class, Parents, Slots) :-
    atom(Class),
    rimuovi_duplicati(Parents, Parents_clean), 
    parents_control(Parents_clean, Class),
    values_control(Slots),
    Term =.. [class, Class, Parents_clean, Slots],
    class_existance(Class, Term),
    !.

%controllo esistenza e consistenza dei parents
parents_control([], _).

parents_control([Class | Tail], Class_name) :-
    atom(Class),
    class(Class, _, _),
    Class \= Class_name,
    parents_control(Tail, Class_name).

%controllo consistenza dei valori di Slots
values_control([]).

values_control([Atom = _ | Tail]) :-
    atom(Atom),
    values_control(Tail).

%controllo che la classe non esista gia'
%se esiste elimino tutte le istanze influenzate
%dal cambiamento e relativo metodo, poi ridefinisco la classe
class_existance(Class, Term) :-
    class(Class, _, _),
    find_classes([Class], [], Out),
    append([Class], Out, Out1),
    rimuovi_duplicati(Out1, Result),
    find_instances(Result, [], Out2),
    rimuovi_duplicati(Out2, Output),
    delete_old_instances(Output),
    retract(class(Class, _, _)),
    assert(Term),
    !.

class_existance(_, Term) :-
    assert(Term),
    !.

%trovo tutte le classi discendenti di Class
find_classes([Class | Tail], Result, Output) :-
    findall(Name, (class(Name, Parents, _),
		   member(Class, Parents)), X),
    append(X, Result, Result1),
    append(X, Tail, Out),
    find_classes(Out, Result1, Output).

find_classes([], Result, Output) :-
    Output = Result,
    !.

%trovo tutte le istanze delle classi presenti nella lista
find_instances([Class | Tail], Result, Output) :-
    findall(Name, instance(Name, Class, _), Out),
    append(Out, Result, Result1),
    find_instances(Tail, Result1, Output).

find_instances([], Result, Output) :-
    Output = Result,
    !.

%cancello tutte le istanze presenti nella lista
delete_old_instances([]) :-
    !.

delete_old_instances([Inst | Tail]) :-
    delete_gate(Inst),
    retract(instance(Inst, _, _)),
    delete_old_instances(Tail),
    !.

%primitiva new\2 e new\3
new(Instance, Class_name) :-
    atom(Instance),
    class(Class_name, _, _),
    delete_gate(Instance),
    instance_existance(Instance),
    Term =.. [instance, Instance, Class_name, []],
    assert(Term),
    findall([Name, Body], get_all(Instance, Name, Body), Out),
    append(Out_clean, [_], Out),
    find_method(Out_clean, Instance, []),
    !.

new(Instance, Class_name, Values) :-
    atom(Instance),
    class(Class_name, _, _),
    values_control(Values),
    class_values(Class_name, Values),
    delete_gate(Instance),
    instance_existance(Instance),
    Term =.. [instance, Instance, Class_name, Values],
    assert(Term),
    findall([Name1, Body1], get_all(Instance, Name1, Body1), Out1),
    append(Out_clean1, [_], Out1),
    find_method(Out_clean1, Instance, []),
    !.

%elimino metodi associati ad una eventuale istanza omonima
%questo predicato funge da trampolino per find_delete_method
delete_gate(Instance) :-
    findall([Name, Body], get_all(Instance, Name, Body), Out),
    append(Out_clean, [_], Out),
    find_delete_method(Out_clean, Instance),
    !.

delete_gate(_) :-
    !.

%elimino eventuale istanza omonima se esistente
instance_existance(Instance) :-
    retract(instance(Instance, _, _)),
    !.

instance_existance(_) :-
    true,
    !.

%controllo che i valori istanziati in new siano consistenti
class_values(_, []).

class_values(Class, [Name = _ | Others]) :-
    getv_hierarchy([Class], Name, _),
    class_values(Class, Others).

%primitiva getv, cerca nell'istanza poi per gerarchia
getv(Instance, Slot, Result) :-
    atom(Slot),
    instance(Instance, _, Values),
    value_in_list(Values, Slot, Result),
    !.

getv(Instance, Slot, Result) :-
    atom(Slot),
    instance(Instance, Classname, _),
    getv_hierarchy([Classname], Slot, Result),
    !.

%variante di getv per utilizzo con findall
get_all(Instance, Slot, Result) :-
    instance(Instance, _, Values),
    value_in_list(Values, Slot, Result).

get_all(Instance, Slot, Result) :-
    instance(Instance, Classname, _),
    getv_hierarchy([Classname], Slot, Result).

%predicato che scorre la gerarchia di classi come da specifica Lisp
getv_hierarchy([], _, _).

getv_hierarchy([Class | _], Slot, Result) :-
    class(Class, _, Values),
    value_in_list(Values, Slot, Result).

getv_hierarchy([Class | Parents], Slot, Result) :-
    class(Class, New_parents, _),
    append(New_parents, Parents, New_list),
    getv_hierarchy(New_list, Slot, Result).

%primitiva getvx come da specifica
getvx(Instance, [Slot], Result) :-
    getv(Instance, Slot, Result).

getvx(Instance, [Slot | Others], Result) :-
    getv(Instance, Slot, Match),
    getvx(Match, Others, Result).

%controllo che un dato valore esista in una lista cosi' fatta
value_in_list([Name = Value | _], Name, Value).

value_in_list([_ = _ | Tail], Name, Result) :-
    value_in_list(Tail, Name, Result).

%true se X non appartiene alla lista
not_member(_, []).

not_member(X, [Y | T]) :-
    X \= Y,
    not_member(X, T).

%rimuovo duplicati in una lista preservandone ordine
rimuovi_duplicati(A, B) :-
    rimuovi_duplicati(A, B, []).
    
rimuovi_duplicati([], [], _).

rimuovi_duplicati([H | T], [H | Out], Old) :-
    not_member(H, Old),
    rimuovi_duplicati(T, Out, [H | Old]).

rimuovi_duplicati([H | T], Out, Old) :-
    member(H, Old),
    rimuovi_duplicati(T, Out, Old).

%preparo il corpo del metodo lavorando su stringhe
prepare_method(Name, Method, Output) :-
    atom_string(Name, Name_string),
    string(Method),
    sub_string(Method, Before, Length, End, "this"),
    !,
    EndThis is Before + Length,
    End_string is End + 4,
    sub_string(Method, 0, _, End_string, Start),
    sub_string(Method, EndThis, _, 0, Out),
    string_concat(Name_string, Out, Output1),
    string_concat(Start, Output1, Output2),
    prepare_method(Name, Output2, Output).

prepare_method(Name, Method_term, Output) :-
    atom_string(Name, Name_string),
    term_string(Method_term, Method),
    sub_string(Method, Before, Length, End, "this"),
    !,
    EndThis is Before + Length,
    End_string is End + 4,
    sub_string(Method, 0, _, End_string, Start),
    sub_string(Method, EndThis, _, 0, Out),
    string_concat(Name_string, Out, Output1),
    string_concat(Start, Output1, Output2),
    prepare_method(Name, Output2, Output).

prepare_method(_, Meth, Out) :-
    string(Meth),
    Out = Meth,
    !.

prepare_method(_, Meth, Out) :-
    term_string(Meth, Out).

%preparo gli argomenti del metodo, lavoro su stringhe
prepare_args(Name, Args, Result) :-
    term_string(Args, String),
    sub_string(String, 1, _, 1, String_clean),
    String_clean \= "",
    atom_string(Name, Name_string),
    string_concat("( ", Name_string, Out),
    string_concat(Out, ", ", Out2),
    string_concat(Out2, String_clean, Out3),
    string_concat(Out3, ")", Result),
    !.

prepare_args(Inst, Args, Result) :-
    term_string(Args, String),
    sub_string(String, 1, _, 1, String_clean),
    atom_string(Inst, Inst_string),
    string_concat("( ", Inst_string, Out),
    string_concat(Out, String_clean, Out2),
    string_concat(Out2, ")", Result),
    !.

%identifico i metodi in una lista generata tramite findall
find_method([], _, _) :-
    !.

find_method([Head | Tail], Instance, Ignore_list) :-
    nth0(0, Head, Name),
    nth0(1, Head, method(Args, Body)),
    not_member(Name, Ignore_list),
    define_method(Name = method(Args, Body), Instance),
    append([Name], Ignore_list, New_list),
    find_method(Tail, Instance, New_list).

find_method([Head | Tail], Instance, Ignore_list) :-
    nth0(0, Head, Name),
    append([Name], Ignore_list, New_list),
    find_method(Tail, Instance, New_list),
    !.

%definisco il metodo
define_method(Name = method(Args, Body), Instance) :-
    prepare_args(Instance, Args, New_args),
    prepare_method(Instance, Body, Body_out),
    atom_string(Name, Name_out),
    string_concat(Name_out, New_args, Out),
    string_concat(Out, ":-", Out2),
    string_concat(Out2, Body_out, Result),
    term_string(Term, Result),
    assert(Term).

%trovo i metodi per poi fare una retract
find_delete_method([], _) :-
    !.

find_delete_method([Head | Tail], Instance) :-
    nth0(0, Head, Name),
    nth0(1, Head, method(Args, Body)),
    delete_method(Name = method(Args, Body), Instance),
    find_delete_method(Tail, Instance).

find_delete_method([_ | Tail], Instance) :-
    find_delete_method(Tail, Instance),
    !.

%retract del metodo
delete_method(Name = method(Args, Body), Instance) :-
    prepare_args(Instance, Args, New_args),
    prepare_method(Instance, Body, Body_out),
    atom_string(Name, Name_out),
    string_concat(Name_out, New_args, Out),
    string_concat(Out, ":-", Out2),
    string_concat(Out2, Body_out, Result),
    term_string(Term, Result),
    retract(Term).

delete_method(_, _) :-
    !.

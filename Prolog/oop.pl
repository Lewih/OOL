def_class(Class, Parents, Slots) :-
    rimuovi_duplicati(Parents, Parents_clean), 
    parents_control(Parents_clean, Class),
    values_control(Slots),
    Term =.. [class, Class, Parents_clean, Slots],
    assert(Term).

class_exist(Class) :-
    class(Class, _, _),
    retract(class(Class, _, _)).

parents_control([], _).

parents_control([Head|Tail], Class_name) :-
    atom(Head),
    class(Head, _, _),
    Head \= Class_name,
    parents_control(Tail, Class_name).

values_control([]).

values_control([Atom = _|Tail]) :-
    atom(Atom),
    values_control(Tail).


new(Instance, Class_name) :-
    class(Class_name, _, _),
    Term =.. [instance, Instance, Class_name, []],
    assert(Term).

new(Instance, Class_name, Values) :-
    class(Class_name, _, _),
    values_control(Values),
    class_values(Class_name, Values),
    Term =.. [instance, Instance, Class_name, Values],
    assert(Term).

class_values(_,[]).


class_values(Class, [Name = _|Others]) :-
    getv_hierarchy([Class], Name, Value),
    is_not_method(Value),
    class_values(Class, Others).

is_not_method(Atom):- 
	atom_string(Atom,Str),
	sub_string(Str,0,6,_,SubStr),
	SubStr\="method".
	
getv(Instance, Slot, Result) :-
    instance(Instance, _, Values),
    value_in_list(Values, Slot,Result).

getv(Instance, Slot, Result) :-
    instance(Instance, Classname, _),
    getv_hierarchy([Classname], Slot, Result).

getv_hierarchy([Class|_], Slot, Result) :-
    class(Class, _, Values),
    value_in_list(Values, Slot, Result).

getv_hierarchy([Class|Parents], Slot, Result) :-
    class(Class, New_parents, _),
    append(New_parents, Parents, New_list),
    getv_hierarchy(New_list, Slot, Result).
	
%suddetta funzione che cerca Slot in Values e che mette in Result il value quando lo trova
value_in_list([Name = Value|_], Name, Value).

value_in_list([_ = _|Tail],Slot,Result) :-
    value_in_list(Tail,Slot,Result).

getvx(Instance, [Slot], Result) :-
    getv(Instance, Slot, Result).

getvx(Instance, [Slot|Others], Result) :-
    getv(Instance, Slot, Match),
    getvx(Match, Others, Result).

	
not_member(X,[]).
not_member(X,[X|T]):- fail.
not_member(X,[Y|T]):- not_member(X,T).
	
%versione corretta ma che usa not, non so per quale motivo non riesco a far andare la not member lol, B è A senza elementi duplicati
rimuovi_duplicati(A,B) :-
    rimuovi_duplicati(A, B, []).
rimuovi_duplicati([],[],_).
rimuovi_duplicati([H|T],[H|Out],Old) :-
    not(member(H,Old)), rimuovi_duplicati(T,Out, [H|Old]).
rimuovi_duplicati([H|T],Out, Old) :-
    member(H,Old), rimuovi_duplicati(T,Out,Old).

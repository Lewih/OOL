parents_control([], _) :-
    true.

parents_control([Head|Tail], Class_name) :-
    atom(Head),
    class(Head, _, _),
    Head \= Class_name,
    parents_control(Tail, Class_name).

values_control([]) :-
    true.

values_control([Atom = _|Tail]) :-
    atom(Atom),
    values_control(Tail).

def_class(Class_name, Parents, Slots) :-
    rimuovi_duplicati(Parents, Parents_clean), 
    parents_control(Parents_clean, Class_name),
    values_control(Slots),
    Term =.. [class, Class_name, Parents_clean, Slots],
    assert(Term).

new(Instance, Class_name) :-
    class(Class_name, _, _),
    Term =.. [instance, Instance, Class_name, []],
    assert(Term).

new(Instance, Class_name, Values) :-
    class(Class_name, _, _),
    values_control(Values),
    Term =.. [instance, Instance, Class_name, Values],
    assert(Term).

getv(Instance, Slot, Result) :-
    instance(Instance, Parents, Values),
    
    !.

%versione migliore ma che tiene l'ultima occorrenza	
%rimuovi_duplicati([], []).
%rimuovi_duplicati([First | Rest], NewRest) :- member(First, Rest), rimuovi_duplicati(Rest, NewRest).
%rimuovi_duplicati([First | Rest], [First | NewRest]) :- not(member(First, Rest)), rimuovi_duplicati(Rest, NewRest).
	
	
not_member(X,[]).
not_member(X,[X|T]):- fail.
not_member(X,[Y|T]):- not_member(X,T).
	
%versione corretta ma che usa not, non so per quale motivo non riesco a far andare la not member lol, B è A senza elementi duplicati
rimuovi_duplicati(A,B) :- rimuovi_duplicati(A, B, []).
rimuovi_duplicati([],[],_).
rimuovi_duplicati([H|T],[H|Out],Old) :- not(member(H,Old)), rimuovi_duplicati(T,Out, [H|Old]).
rimuovi_duplicati([H|T],Out, Old) :- member(H,Old), rimuovi_duplicati(T,Out,Old).
	


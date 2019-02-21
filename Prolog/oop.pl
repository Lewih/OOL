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
    sort(Parents, Parents_clean), %TODO da implementare metodo migliore per rimuovere duplicati
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

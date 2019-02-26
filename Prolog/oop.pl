def_class(Class, Parents, Slots) :-
    rimuovi_duplicati(Parents, Parents_clean), 
    parents_control(Parents_clean, Class),
    values_control(Slots),
    Term =.. [class, Class, Parents_clean, Slots],
    assert(Term),
    !.

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
    assert(Term),
    findall([Name, Body], get_all(Instance, Name, Body), Out),
    append(Out_clean, [_], Out),
    find_method(Out_clean, Instance),!.
    
new(Instance, Class_name, Values) :-
    class(Class_name, _, _),
    values_control(Values),
    class_values(Class_name, Values),
    Term =.. [instance, Instance, Class_name, Values],
    assert(Term),
    findall([Name, Body], get_all(Instance, Name, Body), Out),
    append(Out_clean, [_], Out),
    find_method(Out_clean, Instance),!.

class_values(_, []).

class_values(Class, [Name = _|Others]) :-
    getv_hierarchy([Class], Name, _),
    class_values(Class, Others).
	
getv(Instance, Slot, Result) :-
    instance(Instance, _, Values),
    value_in_list(Values, Slot,Result),!.

getv(Instance, Slot, Result) :-
    instance(Instance, Classname, _),
    getv_hierarchy([Classname], Slot, Result),!.

get_all(Instance, Slot, Result) :-
    instance(Instance, _, Values),
    value_in_list(Values, Slot,Result).

get_all(Instance, Slot, Result) :-
    instance(Instance, Classname, _),
    getv_hierarchy([Classname], Slot, Result).

getv_hierarchy([], _, _).

getv_hierarchy([Class|_], Slot, Result) :-
    class(Class, _, Values),
    value_in_list(Values, Slot, Result).

getv_hierarchy([Class|Parents], Slot, Result) :-
    class(Class, New_parents, _),
    append(New_parents, Parents, New_list),
    getv_hierarchy(New_list, Slot, Result).

getvx(Instance, [Slot], Result) :-
    getv(Instance, Slot, Result).

getvx(Instance, [Slot|Others], Result) :-
    getv(Instance, Slot, Match),
    getvx(Match, Others, Result).

value_in_list([Name = Value|_], Name, Value).

value_in_list([_ = _|Tail],Name,Result) :-
    value_in_list(Tail, Name, Result).

not_member(_, []).

not_member(X, [Y|T]) :-
    X \= Y,
    not_member(X, T).

rimuovi_duplicati([], [], _).

rimuovi_duplicati(A, B) :-
    rimuovi_duplicati(A, B, []).

rimuovi_duplicati([H|T], [H|Out], Old) :-
    not_member(H, Old),
    rimuovi_duplicati(T, Out, [H|Old]).

rimuovi_duplicati([H|T], Out, Old) :-
    member(H, Old),
    rimuovi_duplicati(T, Out, Old).

prepare_method(Name, Method_term, Output) :-
    atom_string(Name, Name_string),
    term_string(Method_term, Method),
    sub_string(Method, Before, Length, End, "this"),
    !,%cut rosso
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

prepare_args(Name, Args, Result) :-
    term_string(Args, String),
    sub_string(String, 1, _, 1, String_clean),
    atom_string(Name, Name_string),
    string_concat("( ", Name_string, Out),
    string_concat(Out, String_clean, Out2),
    string_concat(Out2, ")", Result),
    !.
    
find_method([], _) :-
    !.

find_method([Head|Tail], Instance) :-
    nth0(0, Head, Name),
    nth0(1, Head, method(Args, Body)),
    define_method(Name = method(Args, Body), Instance),
    find_method(Tail, Instance).

find_method([_|Tail], Instance) :-
    find_method(Tail, Instance),
    !.

define_method(Name = method(Args, Body), Instance) :-
    prepare_args(Instance, Args, New_args),
    prepare_method(Instance, Body, Body_out),
    atom_string(Name, Name_out),
    string_concat(Name_out, New_args, Out),
    string_concat(Out, ":-", Out2),
    string_concat(Out2, Body_out, Out3),
    string_concat(Out3, ",!.", Result),
    term_string(Term, Result),
    assert(Term).

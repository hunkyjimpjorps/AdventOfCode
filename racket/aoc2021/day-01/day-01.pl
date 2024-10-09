:- use_module(library(yall)).
:- use_module(library(apply)).

get_data(Result) :- 
    setup_call_cleanup(open("day-01/input.txt", read, In),
        (read_string(In, _, Str),
            split_string(Str, "\n", "\s\t\n", Lines),
            maplist(number_string, Result, Lines)),
        close(In)).

calculate_diffs(Result, WindowWidth) :-
    get_data(Xs),
    length(TrimLeft, WindowWidth), append(TrimLeft, RightSide, Xs),
    length(TrimRight, WindowWidth), append(LeftSide, TrimRight, Xs),
    maplist([X, Y, Z]>>(Z is Y - X), LeftSide, RightSide, Diffs),
    include([X]>>(X > 0), Diffs, Increases),
    length(Increases, Result).

part1_answer(Result) :- calculate_diffs(Result, 1).
part2_answer(Result) :- calculate_diffs(Result, 3).
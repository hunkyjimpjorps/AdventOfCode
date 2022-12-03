:- use_module(library(yall)).
:- use_module(library(apply)).

output_solutions :-
    get_data(Games),
    part1_total(Games, Part1),
    write(Part1), nl, !,
    part2_total(Games, Part2),
    write(Part2), nl.

% Facts

game(X, X, draw). 
game(rock, scissors, win).
game(scissors, paper, win).
game(paper, rock, win).
game(rock, paper, lose).
game(scissors, rock, lose).
game(paper, scissors, lose).
 
opponent_move("A", rock).
opponent_move("B", paper).
opponent_move("C", scissors).

assume_move("X", rock).
assume_move("Y", paper).
assume_move("Z", scissors).

assume_outcome("X", lose).
assume_outcome("Y", draw).
assume_outcome("Z", win).

bonus(rock, 1).
bonus(paper, 2).
bonus(scissors, 3).
bonus(lose, 0).
bonus(draw, 3).
bonus(win, 6). 

% Rules

get_data(Result) :- 
    setup_call_cleanup(open("2022/day-02/prolog-input.txt", read, In),
        (read_string(In, _, Str),
            split_string(Str, "\n", "\s\t\n", Lines),
            maplist([In, Out] >> split_string(In, "\s", "", Out), Lines, Result)),
        close(In)).

score_game(MyMove, Result, Score) :-
    bonus(Result, X),
    bonus(MyMove, Y),
    Score is X + Y.

part1_score([Them, Me], Score) :-
    opponent_move(Them, TheirMove),
    assume_move(Me, MyMove),
    game(MyMove, TheirMove, Result),
    score_game(MyMove, Result, Score).

part1_total(Games, Total) :-
    maplist(part1_score, Games, Scores),
    sum_list(Scores, Total).

part2_score([Them, Outcome], Score) :-
    opponent_move(Them, TheirMove),
    assume_outcome(Outcome, Result),
    game(MyMove, TheirMove, Result),
    score_game(MyMove, Result, Score).

part2_total(Games, Total) :-
    maplist(part2_score, Games, Scores),
    sum_list(Scores, Total).
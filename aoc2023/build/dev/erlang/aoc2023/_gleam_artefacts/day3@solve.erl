-module(day3@solve).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function]).

-export([part1/1, part2/1, main/0]).
-export_type([coord/0, symbol_kind/0, symbol/0, cell/0, part/0]).

-type coord() :: {coord, integer(), integer()}.

-type symbol_kind() :: gear | something_else.

-type symbol() :: {number, integer()} | {symbol, symbol_kind()} | empty.

-type cell() :: {cell, coord(), symbol()}.

-type part() :: {part, list(coord()), integer()}.

-spec to_symbol(binary()) -> symbol().
to_symbol(C) ->
    case {gleam@int:parse(C), C} of
        {{ok, N}, _} ->
            {number, N};

        {_, <<"."/utf8>>} ->
            empty;

        {_, <<"*"/utf8>>} ->
            {symbol, gear};

        {_, _} ->
            {symbol, something_else}
    end.

-spec to_board(binary()) -> gleam@dict:dict(coord(), symbol()).
to_board(Input) ->
    _pipe = (gleam@list:index_map(
        gleam@string:split(Input, <<"\n"/utf8>>),
        fun(Y, R) ->
            gleam@list:index_map(
                gleam@string:to_graphemes(R),
                fun(X, C) -> {{coord, X, Y}, to_symbol(C)} end
            )
        end
    )),
    _pipe@1 = gleam@list:flatten(_pipe),
    gleam@dict:from_list(_pipe@1).

-spec cell_compare(cell(), cell()) -> gleam@order:order().
cell_compare(A, B) ->
    case gleam@int:compare(
        erlang:element(3, erlang:element(2, A)),
        erlang:element(3, erlang:element(2, B))
    ) of
        eq ->
            gleam@int:compare(
                erlang:element(2, erlang:element(2, A)),
                erlang:element(2, erlang:element(2, B))
            );

        Other ->
            Other
    end.

-spec find_all_part_digits(gleam@dict:dict(coord(), symbol())) -> list(cell()).
find_all_part_digits(B) ->
    _pipe = B,
    _pipe@1 = gleam@dict:filter(_pipe, fun(_, V) -> case V of
                {number, _} ->
                    true;

                _ ->
                    false
            end end),
    _pipe@2 = gleam@dict:to_list(_pipe@1),
    _pipe@3 = gleam@list:map(
        _pipe@2,
        fun(Tup) -> {cell, erlang:element(1, Tup), erlang:element(2, Tup)} end
    ),
    gleam@list:sort(_pipe@3, fun cell_compare/2).

-spec do_parts(list(cell()), list(part())) -> list(part()).
do_parts(Cells, Parts) ->
    case Cells of
        [] ->
            Parts;

        [{cell, Next, {number, N}} | T] ->
            case Parts of
                [] ->
                    do_parts(T, [{part, [Next], N} | Parts]);

                [{part, [Prev | _] = Coords, N0} | Rest_parts] ->
                    case {(erlang:element(2, Next) - erlang:element(2, Prev)),
                        (erlang:element(3, Next) - erlang:element(3, Prev))} of
                        {1, 0} ->
                            do_parts(
                                T,
                                [{part, [Next | Coords], (N0 * 10) + N} |
                                    Rest_parts]
                            );

                        {_, _} ->
                            do_parts(T, [{part, [Next], N} | Parts])
                    end;

                _ ->
                    erlang:error(#{gleam_error => panic,
                            message => <<"panic expression evaluated"/utf8>>,
                            module => <<"day3/solve"/utf8>>,
                            function => <<"do_parts"/utf8>>,
                            line => 90})
            end;

        _ ->
            erlang:error(#{gleam_error => panic,
                    message => <<"panic expression evaluated"/utf8>>,
                    module => <<"day3/solve"/utf8>>,
                    function => <<"do_parts"/utf8>>,
                    line => 93})
    end.

-spec to_parts(list(cell())) -> list(part()).
to_parts(Cells) ->
    do_parts(Cells, []).

-spec all_neighbors(coord()) -> list(coord()).
all_neighbors(C) ->
    gleam@list:flat_map(
        [-1, 0, 1],
        fun(Dx) -> gleam@list:filter_map([-1, 0, 1], fun(Dy) -> case {Dx, Dy} of
                        {0, 0} ->
                            {error, nil};

                        {_, _} ->
                            {ok,
                                {coord,
                                    erlang:element(2, C) + Dx,
                                    erlang:element(3, C) + Dy}}
                    end end) end
    ).

-spec sum_valid_parts(integer(), part(), gleam@dict:dict(coord(), symbol())) -> integer().
sum_valid_parts(Acc, Part, Board) ->
    Neighbors = begin
        _pipe = erlang:element(2, Part),
        _pipe@1 = gleam@list:flat_map(_pipe, fun all_neighbors/1),
        gleam@list:unique(_pipe@1)
    end,
    Sym = [{ok, {symbol, gear}}, {ok, {symbol, something_else}}],
    case gleam@list:any(
        Neighbors,
        fun(C) -> gleam@list:contains(Sym, gleam@dict:get(Board, C)) end
    ) of
        true ->
            Acc + erlang:element(3, Part);

        false ->
            Acc
    end.

-spec part1(binary()) -> integer().
part1(Input) ->
    Board = to_board(Input),
    _pipe = Board,
    _pipe@1 = find_all_part_digits(_pipe),
    _pipe@2 = to_parts(_pipe@1),
    gleam@list:fold(
        _pipe@2,
        0,
        fun(Acc, P) -> sum_valid_parts(Acc, P, Board) end
    ).

-spec to_part_with_neighbors(part()) -> part().
to_part_with_neighbors(Part) ->
    _pipe = erlang:element(2, Part),
    _pipe@1 = gleam@list:flat_map(_pipe, fun all_neighbors/1),
    _pipe@2 = gleam@list:unique(_pipe@1),
    {part, _pipe@2, erlang:element(3, Part)}.

-spec find_part_numbers_near_gear(coord(), list(part())) -> list(integer()).
find_part_numbers_near_gear(Gear, Parts) ->
    gleam@list:filter_map(
        Parts,
        fun(Part) -> case gleam@list:contains(erlang:element(2, Part), Gear) of
                true ->
                    {ok, erlang:element(3, Part)};

                false ->
                    {error, nil}
            end end
    ).

-spec to_sum_of_gear_ratios(list(list(integer()))) -> integer().
to_sum_of_gear_ratios(Adjacent_parts) ->
    gleam@list:fold(Adjacent_parts, 0, fun(Acc, Ps) -> case Ps of
                [P1, P2] ->
                    Acc + (P1 * P2);

                _ ->
                    Acc
            end end).

-spec part2(binary()) -> integer().
part2(Input) ->
    Board = to_board(Input),
    Parts = begin
        _pipe = Board,
        _pipe@1 = find_all_part_digits(_pipe),
        _pipe@2 = to_parts(_pipe@1),
        gleam@list:map(_pipe@2, fun to_part_with_neighbors/1)
    end,
    _pipe@3 = Board,
    _pipe@4 = gleam@dict:filter(_pipe@3, fun(_, V) -> V =:= {symbol, gear} end),
    _pipe@5 = gleam@dict:keys(_pipe@4),
    _pipe@6 = gleam@list:map(
        _pipe@5,
        fun(_capture) -> find_part_numbers_near_gear(_capture, Parts) end
    ),
    to_sum_of_gear_ratios(_pipe@6).

-spec main() -> nil.
main() ->
    _assert_subject = adglent:get_part(),
    {ok, Part} = case _assert_subject of
        {ok, _} -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail,
                        module => <<"day3/solve"/utf8>>,
                        function => <<"main"/utf8>>,
                        line => 168})
    end,
    _assert_subject@1 = adglent:get_input(<<"3"/utf8>>),
    {ok, Input} = case _assert_subject@1 of
        {ok, _} -> _assert_subject@1;
        _assert_fail@1 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail@1,
                        module => <<"day3/solve"/utf8>>,
                        function => <<"main"/utf8>>,
                        line => 169})
    end,
    case Part of
        first ->
            _pipe = part1(Input),
            _pipe@1 = adglent:inspect(_pipe),
            gleam@io:println(_pipe@1);

        second ->
            _pipe@2 = part2(Input),
            _pipe@3 = adglent:inspect(_pipe@2),
            gleam@io:println(_pipe@3)
    end.

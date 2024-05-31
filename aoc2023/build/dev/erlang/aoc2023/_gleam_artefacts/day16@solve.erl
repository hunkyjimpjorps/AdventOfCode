-module(day16@solve).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch]).

-export([part1/1, part2/1, main/0]).
-export_type([direction/0, light/0]).

-type direction() :: up | right | down | left.

-type light() :: {light, utilities@array2d:posn(), direction()}.

-spec move(light()) -> light().
move(L) ->
    {light, P, Dir} = L,
    case Dir of
        up ->
            erlang:setelement(
                2,
                L,
                erlang:setelement(2, P, erlang:element(2, P) - 1)
            );

        down ->
            erlang:setelement(
                2,
                L,
                erlang:setelement(2, P, erlang:element(2, P) + 1)
            );

        left ->
            erlang:setelement(
                2,
                L,
                erlang:setelement(3, P, erlang:element(3, P) - 1)
            );

        right ->
            erlang:setelement(
                2,
                L,
                erlang:setelement(3, P, erlang:element(3, P) + 1)
            )
    end.

-spec transform(light(), {ok, binary()} | {error, nil}) -> list(light()).
transform(L, Cell) ->
    gleam@bool:guard(
        gleam@result:is_error(Cell),
        [],
        fun() ->
            {ok, C} = case Cell of
                {ok, _} -> Cell;
                _assert_fail ->
                    erlang:error(#{gleam_error => let_assert,
                                message => <<"Assertion pattern match failed"/utf8>>,
                                value => _assert_fail,
                                module => <<"day16/solve"/utf8>>,
                                function => <<"transform"/utf8>>,
                                line => 33})
            end,
            {light, P, Dir} = L,
            case {Dir, C} of
                {_, <<"."/utf8>>} ->
                    [L];

                {up, <<"|"/utf8>>} ->
                    [L];

                {down, <<"|"/utf8>>} ->
                    [L];

                {left, <<"-"/utf8>>} ->
                    [L];

                {right, <<"-"/utf8>>} ->
                    [L];

                {left, <<"/"/utf8>>} ->
                    [{light, P, down}];

                {down, <<"/"/utf8>>} ->
                    [{light, P, left}];

                {right, <<"/"/utf8>>} ->
                    [{light, P, up}];

                {up, <<"/"/utf8>>} ->
                    [{light, P, right}];

                {left, <<"\\"/utf8>>} ->
                    [{light, P, up}];

                {up, <<"\\"/utf8>>} ->
                    [{light, P, left}];

                {right, <<"\\"/utf8>>} ->
                    [{light, P, down}];

                {down, <<"\\"/utf8>>} ->
                    [{light, P, right}];

                {left, <<"|"/utf8>>} ->
                    [{light, P, up}, {light, P, down}];

                {right, <<"|"/utf8>>} ->
                    [{light, P, up}, {light, P, down}];

                {up, <<"-"/utf8>>} ->
                    [{light, P, left}, {light, P, right}];

                {down, <<"-"/utf8>>} ->
                    [{light, P, left}, {light, P, right}];

                {_, _} ->
                    erlang:error(#{gleam_error => panic,
                            message => <<"unrecognized cell type"/utf8>>,
                            module => <<"day16/solve"/utf8>>,
                            function => <<"transform"/utf8>>,
                            line => 50})
            end
        end
    ).

-spec energize(
    list(light()),
    gleam@set:set(light()),
    gleam@dict:dict(utilities@array2d:posn(), binary())
) -> integer().
energize(Lights, Visited, Grid) ->
    Next_positions = begin
        _pipe = Lights,
        _pipe@1 = gleam@list:flat_map(
            _pipe,
            fun(L) ->
                Next = move(L),
                transform(Next, gleam@dict:get(Grid, erlang:element(2, Next)))
            end
        ),
        gleam@list:filter(
            _pipe@1,
            fun(L@1) -> not gleam@set:contains(Visited, L@1) end
        )
    end,
    All_visited = gleam@set:union(gleam@set:from_list(Next_positions), Visited),
    case Visited =:= All_visited of
        true ->
            _pipe@2 = gleam@set:fold(
                Visited,
                gleam@set:new(),
                fun(Acc, L@2) ->
                    gleam@set:insert(Acc, erlang:element(2, L@2))
                end
            ),
            _pipe@3 = gleam@set:to_list(_pipe@2),
            gleam@list:length(_pipe@3);

        false ->
            energize(Next_positions, All_visited, Grid)
    end.

-spec part1(binary()) -> integer().
part1(Input) ->
    Grid = utilities@array2d:parse_grid(Input),
    _pipe = [{light, {posn, 0, -1}, right}],
    energize(_pipe, gleam@set:new(), Grid).

-spec part2(binary()) -> integer().
part2(Input) ->
    Grid = utilities@array2d:parse_grid(Input),
    {posn, Rows, Cols} = (gleam@list:fold(
        gleam@dict:keys(Grid),
        {posn, 0, 0},
        fun(Acc, P) ->
            case (erlang:element(2, Acc) + erlang:element(3, Acc)) > (erlang:element(
                2,
                P
            )
            + erlang:element(3, P)) of
                true ->
                    Acc;

                false ->
                    P
            end
        end
    )),
    All_starts = gleam@list:concat(
        [gleam@list:map(
                gleam@list:range(0, Rows),
                fun(R) -> {light, {posn, R, -1}, right} end
            ),
            gleam@list:map(
                gleam@list:range(0, Rows),
                fun(R@1) -> {light, {posn, R@1, Cols + 1}, left} end
            ),
            gleam@list:map(
                gleam@list:range(0, Cols),
                fun(C) -> {light, {posn, -1, C}, down} end
            ),
            gleam@list:map(
                gleam@list:range(0, Cols),
                fun(C@1) -> {light, {posn, Rows + 1, C@1}, up} end
            )]
    ),
    gleam@list:fold(
        All_starts,
        0,
        fun(Acc@1, P@1) ->
            Energized = energize([P@1], gleam@set:new(), Grid),
            case Acc@1 > Energized of
                true ->
                    Acc@1;

                false ->
                    Energized
            end
        end
    ).

-spec main() -> nil.
main() ->
    _assert_subject = adglent:get_part(),
    {ok, Part} = case _assert_subject of
        {ok, _} -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail,
                        module => <<"day16/solve"/utf8>>,
                        function => <<"main"/utf8>>,
                        line => 107})
    end,
    _assert_subject@1 = adglent:get_input(<<"16"/utf8>>),
    {ok, Input} = case _assert_subject@1 of
        {ok, _} -> _assert_subject@1;
        _assert_fail@1 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail@1,
                        module => <<"day16/solve"/utf8>>,
                        function => <<"main"/utf8>>,
                        line => 108})
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

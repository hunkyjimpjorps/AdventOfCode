-module(day10@solve).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch]).

-export([part1/1, part2/1, main/0]).
-export_type([posn/0]).

-type posn() :: {posn, integer(), integer()}.

-spec add_posns(posn(), posn()) -> posn().
add_posns(P1, P2) ->
    {posn,
        erlang:element(2, P1) + erlang:element(2, P2),
        erlang:element(3, P1) + erlang:element(3, P2)}.

-spec make_grid(binary()) -> gleam@dict:dict(posn(), binary()).
make_grid(Input) ->
    _pipe = (gleam@list:index_map(
        gleam@string:split(Input, <<"\n"/utf8>>),
        fun(R, Row) ->
            gleam@list:index_map(
                gleam@string:to_graphemes(Row),
                fun(C, Col) -> {{posn, R, C}, Col} end
            )
        end
    )),
    _pipe@1 = gleam@list:flatten(_pipe),
    gleam@dict:from_list(_pipe@1).

-spec count_crossings(
    posn(),
    gleam@set:set(posn()),
    gleam@dict:dict(posn(), binary()),
    integer(),
    binary()
) -> integer().
count_crossings(P, Loop, Grid, Acc, Corner) ->
    Maybe_cell = gleam@dict:get(Grid, P),
    gleam@bool:guard(
        Maybe_cell =:= {error, nil},
        Acc,
        fun() ->
            {ok, Cell} = case Maybe_cell of
                {ok, _} -> Maybe_cell;
                _assert_fail ->
                    erlang:error(#{gleam_error => let_assert,
                                message => <<"Assertion pattern match failed"/utf8>>,
                                value => _assert_fail,
                                module => <<"day10/solve"/utf8>>,
                                function => <<"count_crossings"/utf8>>,
                                line => 125})
            end,
            Next = add_posns(P, {posn, 0, 1}),
            case gleam@set:contains(Loop, P) of
                false ->
                    count_crossings(Next, Loop, Grid, Acc, Corner);

                true ->
                    case {Corner, Cell} of
                        {_, <<"|"/utf8>>} ->
                            count_crossings(Next, Loop, Grid, Acc + 1, Corner);

                        {_, <<"F"/utf8>>} ->
                            count_crossings(Next, Loop, Grid, Acc, Cell);

                        {_, <<"L"/utf8>>} ->
                            count_crossings(Next, Loop, Grid, Acc, Cell);

                        {<<"F"/utf8>>, <<"J"/utf8>>} ->
                            count_crossings(
                                Next,
                                Loop,
                                Grid,
                                Acc + 1,
                                <<""/utf8>>
                            );

                        {<<"L"/utf8>>, <<"7"/utf8>>} ->
                            count_crossings(
                                Next,
                                Loop,
                                Grid,
                                Acc + 1,
                                <<""/utf8>>
                            );

                        {<<"F"/utf8>>, <<"7"/utf8>>} ->
                            count_crossings(Next, Loop, Grid, Acc, <<""/utf8>>);

                        {<<"L"/utf8>>, <<"J"/utf8>>} ->
                            count_crossings(Next, Loop, Grid, Acc, <<""/utf8>>);

                        {_, _} ->
                            count_crossings(Next, Loop, Grid, Acc, Corner)
                    end
            end
        end
    ).

-spec trace_ray(
    posn(),
    gleam@set:set(posn()),
    gleam@dict:dict(posn(), binary())
) -> boolean().
trace_ray(P, Loop, Grid) ->
    gleam@bool:guard(
        gleam@set:contains(Loop, P),
        false,
        fun() ->
            gleam@int:is_odd(count_crossings(P, Loop, Grid, 0, <<""/utf8>>))
        end
    ).

-spec pipe_neighbors(binary()) -> list(posn()).
pipe_neighbors(Pipe) ->
    case Pipe of
        <<"|"/utf8>> ->
            [{posn, -1, 0}, {posn, 1, 0}];

        <<"-"/utf8>> ->
            [{posn, 0, 1}, {posn, 0, -1}];

        <<"L"/utf8>> ->
            [{posn, -1, 0}, {posn, 0, 1}];

        <<"F"/utf8>> ->
            [{posn, 1, 0}, {posn, 0, 1}];

        <<"7"/utf8>> ->
            [{posn, 1, 0}, {posn, 0, -1}];

        <<"J"/utf8>> ->
            [{posn, -1, 0}, {posn, 0, -1}];

        _ ->
            erlang:error(#{gleam_error => panic,
                    message => <<"bad pipe"/utf8>>,
                    module => <<"day10/solve"/utf8>>,
                    function => <<"pipe_neighbors"/utf8>>,
                    line => 44})
    end.

-spec to_next_pipe(posn(), gleam@dict:dict(posn(), binary()), list(posn())) -> list(posn()).
to_next_pipe(Current, Grid, Acc) ->
    [Prev | _] = case Acc of
        [_ | _] -> Acc;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail,
                        module => <<"day10/solve"/utf8>>,
                        function => <<"to_next_pipe"/utf8>>,
                        line => 76})
    end,
    _assert_subject = gleam@dict:get(Grid, Current),
    {ok, Pipe} = case _assert_subject of
        {ok, _} -> _assert_subject;
        _assert_fail@1 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail@1,
                        module => <<"day10/solve"/utf8>>,
                        function => <<"to_next_pipe"/utf8>>,
                        line => 77})
    end,
    gleam@bool:guard(
        Pipe =:= <<"S"/utf8>>,
        [Current | Acc],
        fun() ->
            _assert_subject@1 = begin
                _pipe = Pipe,
                _pipe@1 = pipe_neighbors(_pipe),
                gleam@list:filter_map(
                    _pipe@1,
                    fun(P) -> case add_posns(P, Current) of
                            Neighbor when Neighbor =:= Prev ->
                                {error, nil};

                            Neighbor@1 ->
                                {ok, Neighbor@1}
                        end end
                )
            end,
            [Next] = case _assert_subject@1 of
                [_] -> _assert_subject@1;
                _assert_fail@2 ->
                    erlang:error(#{gleam_error => let_assert,
                                message => <<"Assertion pattern match failed"/utf8>>,
                                value => _assert_fail@2,
                                module => <<"day10/solve"/utf8>>,
                                function => <<"to_next_pipe"/utf8>>,
                                line => 79})
            end,
            to_next_pipe(Next, Grid, [Current | Acc])
        end
    ).

-spec valid_start_direction(gleam@dict:dict(posn(), binary()), posn()) -> posn().
valid_start_direction(Grid, S) ->
    _assert_subject = (gleam@list:filter_map(
        [{{posn, -1, 0}, [<<"|"/utf8>>, <<"7"/utf8>>, <<"F"/utf8>>]},
            {{posn, 1, 0}, [<<"|"/utf8>>, <<"J"/utf8>>, <<"L"/utf8>>]},
            {{posn, 0, 1}, [<<"-"/utf8>>, <<"J"/utf8>>, <<"7"/utf8>>]},
            {{posn, 0, -1}, [<<"-"/utf8>>, <<"F"/utf8>>, <<"L"/utf8>>]}],
        fun(D) ->
            {Delta, Valids} = D,
            Neighbor = add_posns(S, Delta),
            case gleam@dict:get(Grid, Neighbor) of
                {ok, Pipe} ->
                    case gleam@list:contains(Valids, Pipe) of
                        true ->
                            {ok, Neighbor};

                        false ->
                            {error, nil}
                    end;

                {error, _} ->
                    {error, nil}
            end
        end
    )),
    [Dir | _] = case _assert_subject of
        [_ | _] -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail,
                        module => <<"day10/solve"/utf8>>,
                        function => <<"valid_start_direction"/utf8>>,
                        line => 59})
    end,
    Dir.

-spec part1(binary()) -> binary().
part1(Input) ->
    Grid = begin
        _pipe = Input,
        make_grid(_pipe)
    end,
    _assert_subject = begin
        _pipe@1 = Grid,
        _pipe@2 = gleam@dict:filter(
            _pipe@1,
            fun(_, V) -> V =:= <<"S"/utf8>> end
        ),
        _pipe@3 = gleam@dict:keys(_pipe@2),
        gleam@list:first(_pipe@3)
    end,
    {ok, S} = case _assert_subject of
        {ok, _} -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail,
                        module => <<"day10/solve"/utf8>>,
                        function => <<"part1"/utf8>>,
                        line => 97})
    end,
    _pipe@4 = Grid,
    _pipe@5 = valid_start_direction(_pipe@4, S),
    _pipe@6 = to_next_pipe(_pipe@5, Grid, [S]),
    _pipe@7 = gleam@list:length(_pipe@6),
    _pipe@8 = (fun(I) -> ((I - 1) div 2) end)(_pipe@7),
    gleam@string:inspect(_pipe@8).

-spec part2(binary()) -> binary().
part2(Input) ->
    Grid = begin
        _pipe = Input,
        make_grid(_pipe)
    end,
    _assert_subject = begin
        _pipe@1 = Grid,
        _pipe@2 = gleam@dict:filter(
            _pipe@1,
            fun(_, V) -> V =:= <<"S"/utf8>> end
        ),
        _pipe@3 = gleam@dict:keys(_pipe@2),
        gleam@list:first(_pipe@3)
    end,
    {ok, S} = case _assert_subject of
        {ok, _} -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail,
                        module => <<"day10/solve"/utf8>>,
                        function => <<"part2"/utf8>>,
                        line => 145})
    end,
    Loop_pipes = begin
        _pipe@4 = Grid,
        _pipe@5 = valid_start_direction(_pipe@4, S),
        _pipe@6 = to_next_pipe(_pipe@5, Grid, [S]),
        gleam@set:from_list(_pipe@6)
    end,
    _pipe@7 = Grid,
    _pipe@8 = gleam@dict:keys(_pipe@7),
    _pipe@9 = gleam@list:filter(
        _pipe@8,
        fun(_capture) -> trace_ray(_capture, Loop_pipes, Grid) end
    ),
    _pipe@10 = gleam@list:length(_pipe@9),
    gleam@string:inspect(_pipe@10).

-spec main() -> nil.
main() ->
    _assert_subject = adglent:get_part(),
    {ok, Part} = case _assert_subject of
        {ok, _} -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail,
                        module => <<"day10/solve"/utf8>>,
                        function => <<"main"/utf8>>,
                        line => 165})
    end,
    _assert_subject@1 = adglent:get_input(<<"10"/utf8>>),
    {ok, Input} = case _assert_subject@1 of
        {ok, _} -> _assert_subject@1;
        _assert_fail@1 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail@1,
                        module => <<"day10/solve"/utf8>>,
                        function => <<"main"/utf8>>,
                        line => 166})
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

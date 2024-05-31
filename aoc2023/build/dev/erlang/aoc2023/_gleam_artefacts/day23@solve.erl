-module(day23@solve).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch]).

-export([part1/1, part2/1, main/0]).
-export_type([path/0, route/0]).

-type path() :: unknown | straight | junction.

-type route() :: {route, utilities@array2d:posn(), integer()}.

-spec append_to_key(gleam@option:option(list(RTF)), RTF) -> list(RTF).
append_to_key(V, New) ->
    case V of
        none ->
            [New];

        {some, Xs} ->
            [New | Xs]
    end.

-spec first_parse_path(binary()) -> {ok, path()} | {error, nil}.
first_parse_path(C) ->
    case C of
        <<"#"/utf8>> ->
            {error, nil};

        _ ->
            {ok, unknown}
    end.

-spec junction_neighbors(utilities@array2d:posn()) -> list(utilities@array2d:posn()).
junction_neighbors(P) ->
    [erlang:setelement(2, P, erlang:element(2, P) + 1),
        erlang:setelement(3, P, erlang:element(3, P) + 1)].

-spec mark_junctions(gleam@dict:dict(utilities@array2d:posn(), path())) -> gleam@dict:dict(utilities@array2d:posn(), path()).
mark_junctions(Trails) ->
    gleam@dict:map_values(
        Trails,
        fun(Trail, _) ->
            Valid_neighbors = begin
                _pipe = Trail,
                _pipe@1 = utilities@array2d:ortho_neighbors(_pipe),
                gleam@list:filter(
                    _pipe@1,
                    fun(_capture) -> gleam@dict:has_key(Trails, _capture) end
                )
            end,
            case gleam@list:length(Valid_neighbors) of
                2 ->
                    straight;

                _ ->
                    junction
            end
        end
    ).

-spec walk_to_next_junction(
    utilities@array2d:posn(),
    utilities@array2d:posn(),
    integer(),
    gleam@set:set(utilities@array2d:posn()),
    gleam@dict:dict(utilities@array2d:posn(), path())
) -> {utilities@array2d:posn(), route()}.
walk_to_next_junction(Start, Current, Length, Seen, Trails) ->
    _assert_subject = begin
        _pipe = Current,
        _pipe@1 = utilities@array2d:ortho_neighbors(_pipe),
        gleam@list:filter(
            _pipe@1,
            fun(N) ->
                gleam@dict:has_key(Trails, N) andalso not gleam@set:contains(
                    Seen,
                    N
                )
            end
        )
    end,
    [Next] = case _assert_subject of
        [_] -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail,
                        module => <<"day23/solve"/utf8>>,
                        function => <<"walk_to_next_junction"/utf8>>,
                        line => 73})
    end,
    case gleam@dict:get(Trails, Next) of
        {ok, junction} ->
            {Start, {route, Next, Length + 1}};

        _ ->
            Seen@1 = gleam@set:insert(Seen, Current),
            walk_to_next_junction(Start, Next, (Length + 1), Seen@1, Trails)
    end.

-spec start_walking_to_next_junction(
    utilities@array2d:posn(),
    utilities@array2d:posn(),
    gleam@dict:dict(utilities@array2d:posn(), path())
) -> {utilities@array2d:posn(), route()}.
start_walking_to_next_junction(Start, Next, Trails) ->
    Seen = begin
        _pipe = gleam@set:new(),
        _pipe@1 = gleam@set:insert(_pipe, Start),
        gleam@set:insert(_pipe@1, Next)
    end,
    walk_to_next_junction(Start, Next, 1, Seen, Trails).

-spec find_routes(
    list(utilities@array2d:posn()),
    gleam@dict:dict(utilities@array2d:posn(), path())
) -> list({utilities@array2d:posn(), route()}).
find_routes(Junctions, Trails) ->
    gleam@list:flat_map(
        Junctions,
        fun(Junction) ->
            gleam@list:filter_map(
                junction_neighbors(Junction),
                fun(Neighbor) -> case gleam@dict:has_key(Trails, Neighbor) of
                        true ->
                            {ok,
                                start_walking_to_next_junction(
                                    Junction,
                                    Neighbor,
                                    Trails
                                )};

                        false ->
                            {error, nil}
                    end end
            )
        end
    ).

-spec generate_routes(
    list(utilities@array2d:posn()),
    gleam@dict:dict(utilities@array2d:posn(), path())
) -> gleam@dict:dict(utilities@array2d:posn(), list(route())).
generate_routes(Junctions, Trails) ->
    gleam@list:fold(
        find_routes(Junctions, Trails),
        gleam@dict:new(),
        fun(Acc, _use1) ->
            {From, Route} = _use1,
            gleam@dict:update(
                Acc,
                From,
                fun(_capture) -> append_to_key(_capture, Route) end
            )
        end
    ).

-spec generate_2way_routes(
    list(utilities@array2d:posn()),
    gleam@dict:dict(utilities@array2d:posn(), path())
) -> gleam@dict:dict(utilities@array2d:posn(), list(route())).
generate_2way_routes(Junctions, Trails) ->
    gleam@list:fold(
        find_routes(Junctions, Trails),
        gleam@dict:new(),
        fun(Acc, _use1) ->
            {From, Route} = _use1,
            _pipe = Acc,
            _pipe@1 = gleam@dict:update(
                _pipe,
                From,
                fun(_capture) -> append_to_key(_capture, Route) end
            ),
            gleam@dict:update(
                _pipe@1,
                erlang:element(2, Route),
                fun(_capture@1) ->
                    append_to_key(
                        _capture@1,
                        {route, From, erlang:element(3, Route)}
                    )
                end
            )
        end
    ).

-spec do_dfs(
    gleam@dict:dict(utilities@array2d:posn(), list(route())),
    utilities@array2d:posn(),
    utilities@array2d:posn(),
    integer(),
    gleam@set:set(utilities@array2d:posn())
) -> integer().
do_dfs(Routes, From, To, Acc, Seen) ->
    gleam@bool:guard(
        To =:= From,
        Acc,
        fun() ->
            _assert_subject = gleam@dict:get(Routes, From),
            {ok, All_routes} = case _assert_subject of
                {ok, _} -> _assert_subject;
                _assert_fail ->
                    erlang:error(#{gleam_error => let_assert,
                                message => <<"Assertion pattern match failed"/utf8>>,
                                value => _assert_fail,
                                module => <<"day23/solve"/utf8>>,
                                function => <<"do_dfs"/utf8>>,
                                line => 134})
            end,
            Neighbors = gleam@list:filter(
                All_routes,
                fun(R) -> not gleam@set:contains(Seen, erlang:element(2, R)) end
            ),
            case Neighbors of
                [] ->
                    0;

                Neighbors@1 ->
                    gleam@list:fold(
                        Neighbors@1,
                        Acc,
                        fun(Inner_acc, N) ->
                            Score = do_dfs(
                                Routes,
                                erlang:element(2, N),
                                To,
                                Acc + erlang:element(3, N),
                                gleam@set:insert(Seen, erlang:element(2, N))
                            ),
                            gleam@int:max(Score, Inner_acc)
                        end
                    )
            end
        end
    ).

-spec dfs(
    gleam@dict:dict(utilities@array2d:posn(), list(route())),
    utilities@array2d:posn(),
    utilities@array2d:posn()
) -> integer().
dfs(Routes, From, To) ->
    Seen = gleam@set:insert(gleam@set:new(), From),
    do_dfs(Routes, From, To, 0, Seen).

-spec solve_using(
    binary(),
    fun((list(utilities@array2d:posn()), gleam@dict:dict(utilities@array2d:posn(), path())) -> gleam@dict:dict(utilities@array2d:posn(), list(route())))
) -> integer().
solve_using(Input, Using) ->
    Min_row = 0,
    Max_row = gleam@list:length(gleam@string:split(Input, <<"\n"/utf8>>)) - 1,
    Trails = begin
        _pipe = Input,
        _pipe@1 = utilities@array2d:parse_grid_using(
            _pipe,
            fun first_parse_path/1
        ),
        mark_junctions(_pipe@1)
    end,
    Junctions = begin
        _pipe@2 = Trails,
        _pipe@3 = gleam@dict:filter(_pipe@2, fun(_, V) -> V =:= junction end),
        gleam@dict:keys(_pipe@3)
    end,
    _assert_subject = gleam@list:find(
        Junctions,
        fun(J) -> erlang:element(2, J) =:= Min_row end
    ),
    {ok, Start} = case _assert_subject of
        {ok, _} -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail,
                        module => <<"day23/solve"/utf8>>,
                        function => <<"solve_using"/utf8>>,
                        line => 165})
    end,
    _assert_subject@1 = gleam@list:find(
        Junctions,
        fun(J@1) -> erlang:element(2, J@1) =:= Max_row end
    ),
    {ok, End} = case _assert_subject@1 of
        {ok, _} -> _assert_subject@1;
        _assert_fail@1 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail@1,
                        module => <<"day23/solve"/utf8>>,
                        function => <<"solve_using"/utf8>>,
                        line => 166})
    end,
    Routes = Using(Junctions, Trails),
    dfs(Routes, Start, End).

-spec part1(binary()) -> integer().
part1(Input) ->
    solve_using(Input, fun generate_routes/2).

-spec part2(binary()) -> integer().
part2(Input) ->
    solve_using(Input, fun generate_2way_routes/2).

-spec main() -> nil.
main() ->
    _assert_subject = adglent:get_part(),
    {ok, Part} = case _assert_subject of
        {ok, _} -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail,
                        module => <<"day23/solve"/utf8>>,
                        function => <<"main"/utf8>>,
                        line => 182})
    end,
    _assert_subject@1 = adglent:get_input(<<"23"/utf8>>),
    {ok, Input} = case _assert_subject@1 of
        {ok, _} -> _assert_subject@1;
        _assert_fail@1 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail@1,
                        module => <<"day23/solve"/utf8>>,
                        function => <<"main"/utf8>>,
                        line => 183})
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

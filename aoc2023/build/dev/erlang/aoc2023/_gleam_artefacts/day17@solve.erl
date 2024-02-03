-module(day17@solve).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function]).

-export([part1/1, part2/1, main/0]).
-export_type([state/0]).

-type state() :: {state,
        utilities@array2d:posn(),
        integer(),
        utilities@array2d:posn(),
        list(utilities@array2d:posn())}.

-spec same_dir(state()) -> list(utilities@array2d:posn()).
same_dir(S) ->
    case erlang:element(5, S) of
        [] ->
            [];

        [First | _] = Deltas ->
            _pipe = gleam@list:take_while(Deltas, fun(D) -> D =:= First end),
            gleam@list:take(_pipe, 10)
    end.

-spec make_key(state()) -> {utilities@array2d:posn(),
    list(utilities@array2d:posn())}.
make_key(S) ->
    {erlang:element(2, S), same_dir(S)}.

-spec is_goal(state(), integer(), utilities@array2d:posn()) -> boolean().
is_goal(S, Min_run, Goal) ->
    (Goal =:= erlang:element(2, S)) andalso (gleam@list:length(same_dir(S)) >= Min_run).

-spec eliminate_bad_neighbors(
    utilities@array2d:posn(),
    state(),
    integer(),
    integer(),
    gleam@dict:dict(utilities@array2d:posn(), any())
) -> boolean().
eliminate_bad_neighbors(D, S, Max, Min, Grid) ->
    Neighbor = utilities@array2d:add_posns(D, erlang:element(2, S)),
    gleam@bool:guard(
        (Neighbor =:= erlang:element(4, S)) orelse not gleam@dict:has_key(
            Grid,
            Neighbor
        ),
        false,
        fun() -> case {same_dir(S), gleam@list:length(same_dir(S))} of
                {[Prev | _], L} when L =:= Max ->
                    D /= Prev;

                {_, 0} ->
                    true;

                {[Prev@1 | _], L@1} when L@1 < Min ->
                    D =:= Prev@1;

                {_, _} ->
                    true
            end end
    ).

-spec make_state(
    utilities@array2d:posn(),
    state(),
    gleam@dict:dict(utilities@array2d:posn(), integer())
) -> state().
make_state(D, S, Grid) ->
    Neighbor = utilities@array2d:add_posns(D, erlang:element(2, S)),
    _assert_subject = gleam@dict:get(Grid, Neighbor),
    {ok, Heat_lost} = case _assert_subject of
        {ok, _} -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail,
                        module => <<"day17/solve"/utf8>>,
                        function => <<"make_state"/utf8>>,
                        line => 58})
    end,
    {state,
        Neighbor,
        erlang:element(3, S) + Heat_lost,
        erlang:element(2, S),
        [D | erlang:element(5, S)]}.

-spec find_good_neighbors(
    integer(),
    integer(),
    state(),
    gleam@dict:dict(utilities@array2d:posn(), integer())
) -> list(state()).
find_good_neighbors(Max, Min, S, Grid) ->
    _pipe = [{posn, -1, 0}, {posn, 1, 0}, {posn, 0, -1}, {posn, 0, 1}],
    _pipe@1 = gleam@list:filter(
        _pipe,
        fun(_capture) ->
            eliminate_bad_neighbors(_capture, S, Max, Min, Grid)
        end
    ),
    gleam@list:map(
        _pipe@1,
        fun(_capture@1) -> make_state(_capture@1, S, Grid) end
    ).

-spec find_path(
    gleam@dict:dict(utilities@array2d:posn(), integer()),
    utilities@prioqueue:priority_queue(state()),
    gleam@set:set({utilities@array2d:posn(), list(utilities@array2d:posn())}),
    fun((state()) -> list(state())),
    fun((state()) -> boolean())
) -> integer().
find_path(Grid, Queue, Seen, Get_neighbors, Is_goal) ->
    _assert_subject = utilities@prioqueue:pop(Queue),
    {ok, {State, Rest}} = case _assert_subject of
        {ok, {_, _}} -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail,
                        module => <<"day17/solve"/utf8>>,
                        function => <<"find_path"/utf8>>,
                        line => 74})
    end,
    Key = make_key(
        begin
            _pipe = State,
            gleam@io:debug(_pipe)
        end
    ),
    case gleam@set:contains(Seen, Key) of
        true ->
            find_path(Grid, Rest, Seen, Get_neighbors, Is_goal);

        false ->
            Now_seen = gleam@set:insert(Seen, Key),
            Neighbors = Get_neighbors(State),
            case gleam@list:find(Neighbors, Is_goal) of
                {ok, Final} ->
                    erlang:element(3, Final);

                _ ->
                    Now_queue = gleam@list:fold(
                        Neighbors,
                        Rest,
                        fun(Acc, N) ->
                            utilities@prioqueue:insert(
                                Acc,
                                N,
                                erlang:element(3, N)
                            )
                        end
                    ),
                    find_path(Grid, Now_queue, Now_seen, Get_neighbors, Is_goal)
            end
    end.

-spec part1(binary()) -> binary().
part1(Input) ->
    Raw_grid = begin
        _pipe = Input,
        utilities@array2d:to_list_of_lists(_pipe)
    end,
    Grid = utilities@array2d:to_2d_intarray(Raw_grid),
    Rmax = gleam@list:length(Raw_grid),
    _assert_subject = begin
        _pipe@1 = Raw_grid,
        _pipe@2 = gleam@list:first(_pipe@1),
        gleam@result:map(_pipe@2, fun gleam@list:length/1)
    end,
    {ok, Cmax} = case _assert_subject of
        {ok, _} -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail,
                        module => <<"day17/solve"/utf8>>,
                        function => <<"part1"/utf8>>,
                        line => 107})
    end,
    Start = {state, {posn, 0, 0}, 0, {posn, 0, 0}, []},
    Goal = {posn, Rmax, Cmax},
    _pipe@3 = find_path(
        Grid,
        utilities@prioqueue:insert(utilities@prioqueue:new(), Start, 0),
        gleam@set:new(),
        fun(_capture) -> find_good_neighbors(0, 3, _capture, Grid) end,
        fun(_capture@1) -> is_goal(_capture@1, 1, Goal) end
    ),
    gleam@string:inspect(_pipe@3).

-spec part2(binary()) -> binary().
part2(Input) ->
    _pipe = Input,
    gleam@string:inspect(_pipe).

-spec main() -> nil.
main() ->
    _assert_subject = adglent:get_part(),
    {ok, Part} = case _assert_subject of
        {ok, _} -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail,
                        module => <<"day17/solve"/utf8>>,
                        function => <<"main"/utf8>>,
                        line => 131})
    end,
    _assert_subject@1 = adglent:get_input(<<"17"/utf8>>),
    {ok, Input} = case _assert_subject@1 of
        {ok, _} -> _assert_subject@1;
        _assert_fail@1 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail@1,
                        module => <<"day17/solve"/utf8>>,
                        function => <<"main"/utf8>>,
                        line => 132})
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

-module(day8@solve).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch]).

-export([part1/1, part2/1, main/0]).
-export_type([paths/0]).

-type paths() :: {paths, binary(), binary()}.

-spec parse(binary()) -> {gleam@iterator:iterator(binary()),
    gleam@dict:dict(binary(), paths())}.
parse(Input) ->
    _assert_subject = gleam@string:split(Input, <<"\n\n"/utf8>>),
    [Directions_str, Maze_str] = case _assert_subject of
        [_, _] -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail,
                        module => <<"day8/solve"/utf8>>,
                        function => <<"parse"/utf8>>,
                        line => 20})
    end,
    Directions = begin
        _pipe = Directions_str,
        _pipe@1 = gleam@string:to_graphemes(_pipe),
        _pipe@2 = gleam@iterator:from_list(_pipe@1),
        gleam@iterator:cycle(_pipe@2)
    end,
    _assert_subject@1 = gleam@regex:from_string(
        <<"(...) = \\((...), (...)\\)"/utf8>>
    ),
    {ok, Re} = case _assert_subject@1 of
        {ok, _} -> _assert_subject@1;
        _assert_fail@1 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail@1,
                        module => <<"day8/solve"/utf8>>,
                        function => <<"parse"/utf8>>,
                        line => 28})
    end,
    Maze = begin
        _pipe@3 = Maze_str,
        _pipe@4 = gleam@string:split(_pipe@3, <<"\n"/utf8>>),
        _pipe@5 = gleam@list:map(
            _pipe@4,
            fun(Str) ->
                _assert_subject@2 = gleam@regex:scan(Re, Str),
                [{match, _, [{some, Name}, {some, Left}, {some, Right}]}] = case _assert_subject@2 of
                    [{match, _, [{some, _}, {some, _}, {some, _}]}] -> _assert_subject@2;
                    _assert_fail@2 ->
                        erlang:error(#{gleam_error => let_assert,
                                    message => <<"Assertion pattern match failed"/utf8>>,
                                    value => _assert_fail@2,
                                    module => <<"day8/solve"/utf8>>,
                                    function => <<"parse"/utf8>>,
                                    line => 33})
                end,
                {Name, {paths, Left, Right}}
            end
        ),
        gleam@dict:from_list(_pipe@5)
    end,
    {Directions, Maze}.

-spec to_next_step(
    binary(),
    binary(),
    integer(),
    gleam@iterator:iterator(binary()),
    gleam@dict:dict(binary(), paths())
) -> integer().
to_next_step(Current, Stop_at, Count, Directions, Maze) ->
    gleam@bool:guard(
        gleam@string:ends_with(Current, Stop_at),
        Count,
        fun() ->
            _assert_subject = gleam@iterator:step(Directions),
            {next, Next_direction, Rest_directions} = case _assert_subject of
                {next, _, _} -> _assert_subject;
                _assert_fail ->
                    erlang:error(#{gleam_error => let_assert,
                                message => <<"Assertion pattern match failed"/utf8>>,
                                value => _assert_fail,
                                module => <<"day8/solve"/utf8>>,
                                function => <<"to_next_step"/utf8>>,
                                line => 50})
            end,
            _assert_subject@1 = gleam@dict:get(Maze, Current),
            {ok, Paths} = case _assert_subject@1 of
                {ok, _} -> _assert_subject@1;
                _assert_fail@1 ->
                    erlang:error(#{gleam_error => let_assert,
                                message => <<"Assertion pattern match failed"/utf8>>,
                                value => _assert_fail@1,
                                module => <<"day8/solve"/utf8>>,
                                function => <<"to_next_step"/utf8>>,
                                line => 51})
            end,
            _pipe = case Next_direction of
                <<"L"/utf8>> ->
                    erlang:element(2, Paths);

                <<"R"/utf8>> ->
                    erlang:element(3, Paths);

                _ ->
                    erlang:error(#{gleam_error => panic,
                            message => <<"bad direction"/utf8>>,
                            module => <<"day8/solve"/utf8>>,
                            function => <<"to_next_step"/utf8>>,
                            line => 55})
            end,
            to_next_step(_pipe, Stop_at, Count + 1, Rest_directions, Maze)
        end
    ).

-spec part1(binary()) -> integer().
part1(Input) ->
    {Directions, Maze} = parse(Input),
    to_next_step(<<"AAA"/utf8>>, <<"ZZZ"/utf8>>, 0, Directions, Maze).

-spec part2(binary()) -> integer().
part2(Input) ->
    {Directions, Maze} = parse(Input),
    gleam@list:fold(
        gleam@dict:keys(Maze),
        1,
        fun(Acc, Name) -> case gleam@string:ends_with(Name, <<"A"/utf8>>) of
                false ->
                    Acc;

                true ->
                    _pipe = to_next_step(
                        Name,
                        <<"Z"/utf8>>,
                        0,
                        Directions,
                        Maze
                    ),
                    gleam_community@maths@arithmetics:lcm(_pipe, Acc)
            end end
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
                        module => <<"day8/solve"/utf8>>,
                        function => <<"main"/utf8>>,
                        line => 79})
    end,
    _assert_subject@1 = adglent:get_input(<<"8"/utf8>>),
    {ok, Input} = case _assert_subject@1 of
        {ok, _} -> _assert_subject@1;
        _assert_fail@1 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail@1,
                        module => <<"day8/solve"/utf8>>,
                        function => <<"main"/utf8>>,
                        line => 80})
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

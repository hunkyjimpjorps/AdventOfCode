-module(day21@solve).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch]).

-export([part1/1, part2/1, main/0]).

-spec part1(binary()) -> any().
part1(Input) ->
    erlang:error(#{gleam_error => todo,
            message => <<"Implement solution to part 1"/utf8>>,
            module => <<"day21/solve"/utf8>>,
            function => <<"part1"/utf8>>,
            line => 5}).

-spec part2(binary()) -> any().
part2(Input) ->
    erlang:error(#{gleam_error => todo,
            message => <<"Implement solution to part 2"/utf8>>,
            module => <<"day21/solve"/utf8>>,
            function => <<"part2"/utf8>>,
            line => 9}).

-spec main() -> nil.
main() ->
    _assert_subject = adglent:get_part(),
    {ok, Part} = case _assert_subject of
        {ok, _} -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail,
                        module => <<"day21/solve"/utf8>>,
                        function => <<"main"/utf8>>,
                        line => 13})
    end,
    _assert_subject@1 = adglent:get_input(<<"21"/utf8>>),
    {ok, Input} = case _assert_subject@1 of
        {ok, _} -> _assert_subject@1;
        _assert_fail@1 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail@1,
                        module => <<"day21/solve"/utf8>>,
                        function => <<"main"/utf8>>,
                        line => 14})
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

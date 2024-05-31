-module(day9@solve).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch]).

-export([part1/1, part2/1, main/0]).

-spec maybe_backwards(list(SLN), boolean()) -> list(SLN).
maybe_backwards(Xs, Backwards) ->
    case Backwards of
        false ->
            gleam@list:reverse(Xs);

        true ->
            Xs
    end.

-spec parse(binary(), boolean()) -> list(list(integer())).
parse(Input, Backwards) ->
    gleam@list:map(
        gleam@string:split(Input, <<"\n"/utf8>>),
        fun(Line) ->
            gleam@list:map(
                maybe_backwards(
                    gleam@string:split(Line, <<" "/utf8>>),
                    Backwards
                ),
                fun(N_str) ->
                    _assert_subject = gleam@int:parse(N_str),
                    {ok, N} = case _assert_subject of
                        {ok, _} -> _assert_subject;
                        _assert_fail ->
                            erlang:error(#{gleam_error => let_assert,
                                        message => <<"Assertion pattern match failed"/utf8>>,
                                        value => _assert_fail,
                                        module => <<"day9/solve"/utf8>>,
                                        function => <<"parse"/utf8>>,
                                        line => 10})
                    end,
                    N
                end
            )
        end
    ).

-spec is_constant(list(integer())) -> boolean().
is_constant(Ns) ->
    case gleam@list:unique(Ns) of
        [_] ->
            true;

        _ ->
            false
    end.

-spec take_derivative(list(integer())) -> list(integer()).
take_derivative(Ns) ->
    _pipe = Ns,
    _pipe@1 = gleam@list:window_by_2(_pipe),
    gleam@list:map(
        _pipe@1,
        fun(Tup) -> erlang:element(1, Tup) - erlang:element(2, Tup) end
    ).

-spec extrapolate(list(integer())) -> integer().
extrapolate(Ns) ->
    case {is_constant(Ns), Ns} of
        {true, [N | _]} ->
            N;

        {false, [N@1 | _]} ->
            N@1 + extrapolate(take_derivative(Ns));

        {_, _} ->
            erlang:error(#{gleam_error => panic,
                    message => <<"list empty when it shouldn't be"/utf8>>,
                    module => <<"day9/solve"/utf8>>,
                    function => <<"extrapolate"/utf8>>,
                    line => 38})
    end.

-spec part(binary(), boolean()) -> binary().
part(Input, Backwards) ->
    _pipe = Input,
    _pipe@1 = parse(_pipe, Backwards),
    _pipe@2 = gleam@list:fold(
        _pipe@1,
        0,
        fun(Acc, Ns) -> extrapolate(Ns) + Acc end
    ),
    gleam@string:inspect(_pipe@2).

-spec part1(binary()) -> binary().
part1(Input) ->
    part(Input, false).

-spec part2(binary()) -> binary().
part2(Input) ->
    part(Input, true).

-spec main() -> nil.
main() ->
    _assert_subject = adglent:get_part(),
    {ok, Part} = case _assert_subject of
        {ok, _} -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail,
                        module => <<"day9/solve"/utf8>>,
                        function => <<"main"/utf8>>,
                        line => 58})
    end,
    _assert_subject@1 = adglent:get_input(<<"9"/utf8>>),
    {ok, Input} = case _assert_subject@1 of
        {ok, _} -> _assert_subject@1;
        _assert_fail@1 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail@1,
                        module => <<"day9/solve"/utf8>>,
                        function => <<"main"/utf8>>,
                        line => 59})
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

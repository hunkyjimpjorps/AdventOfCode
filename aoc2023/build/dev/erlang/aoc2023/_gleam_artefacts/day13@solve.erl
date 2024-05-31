-module(day13@solve).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch]).

-export([part1/1, part2/1, main/0]).
-export_type([symmetry_type/0]).

-type symmetry_type() :: {horizontal, integer()} | {vertical, integer()}.

-spec do_is_symmetric(list(list(BVU)), list(list(BVU)), integer()) -> {ok,
        integer()} |
    {error, nil}.
do_is_symmetric(Left, Right, Errors) ->
    gleam@bool:guard(
        gleam@list:is_empty(Right),
        {error, nil},
        fun() ->
            [H | T] = case Right of
                [_ | _] -> Right;
                _assert_fail ->
                    erlang:error(#{gleam_error => let_assert,
                                message => <<"Assertion pattern match failed"/utf8>>,
                                value => _assert_fail,
                                module => <<"day13/solve"/utf8>>,
                                function => <<"do_is_symmetric"/utf8>>,
                                line => 23})
            end,
            Found_errors = begin
                _pipe = gleam@list:zip(
                    gleam@list:flatten(Left),
                    gleam@list:flatten(Right)
                ),
                _pipe@1 = gleam@list:filter(
                    _pipe,
                    fun(Tup) ->
                        erlang:element(2, Tup) /= erlang:element(1, Tup)
                    end
                ),
                gleam@list:length(_pipe@1)
            end,
            case Found_errors =:= Errors of
                true ->
                    {ok, gleam@list:length(Left)};

                false ->
                    do_is_symmetric([H | Left], T, Errors)
            end
        end
    ).

-spec is_symmetric(list(list(any())), integer()) -> {ok, integer()} |
    {error, nil}.
is_symmetric(Xss, Errs) ->
    [Left | Right] = case Xss of
        [_ | _] -> Xss;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail,
                        module => <<"day13/solve"/utf8>>,
                        function => <<"is_symmetric"/utf8>>,
                        line => 13})
    end,
    do_is_symmetric([Left], Right, Errs).

-spec get_symmetry_type(list(list(binary())), integer()) -> symmetry_type().
get_symmetry_type(Xss, Errors) ->
    case is_symmetric(Xss, Errors) of
        {ok, N} ->
            {horizontal, N};

        _ ->
            _assert_subject = is_symmetric(gleam@list:transpose(Xss), Errors),
            {ok, N@1} = case _assert_subject of
                {ok, _} -> _assert_subject;
                _assert_fail ->
                    erlang:error(#{gleam_error => let_assert,
                                message => <<"Assertion pattern match failed"/utf8>>,
                                value => _assert_fail,
                                module => <<"day13/solve"/utf8>>,
                                function => <<"get_symmetry_type"/utf8>>,
                                line => 38})
            end,
            {vertical, N@1}
    end.

-spec summarize_notes(list(symmetry_type())) -> integer().
summarize_notes(Symmetries) ->
    gleam@list:fold(Symmetries, 0, fun(Acc, Note) -> Acc + case Note of
                {horizontal, N} ->
                    100 * N;

                {vertical, N@1} ->
                    N@1
            end end).

-spec solve(binary(), integer()) -> binary().
solve(Input, Errors) ->
    _pipe = Input,
    _pipe@1 = gleam@string:split(_pipe, <<"\n\n"/utf8>>),
    _pipe@5 = gleam@list:map(_pipe@1, fun(Strs) -> _pipe@2 = Strs,
            _pipe@3 = gleam@string:split(_pipe@2, <<"\n"/utf8>>),
            _pipe@4 = gleam@list:map(_pipe@3, fun gleam@string:to_graphemes/1),
            get_symmetry_type(_pipe@4, Errors) end),
    _pipe@6 = summarize_notes(_pipe@5),
    gleam@string:inspect(_pipe@6).

-spec part1(binary()) -> binary().
part1(Input) ->
    solve(Input, 0).

-spec part2(binary()) -> binary().
part2(Input) ->
    solve(Input, 1).

-spec main() -> nil.
main() ->
    _assert_subject = adglent:get_part(),
    {ok, Part} = case _assert_subject of
        {ok, _} -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail,
                        module => <<"day13/solve"/utf8>>,
                        function => <<"main"/utf8>>,
                        line => 75})
    end,
    _assert_subject@1 = adglent:get_input(<<"13"/utf8>>),
    {ok, Input} = case _assert_subject@1 of
        {ok, _} -> _assert_subject@1;
        _assert_fail@1 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail@1,
                        module => <<"day13/solve"/utf8>>,
                        function => <<"main"/utf8>>,
                        line => 76})
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

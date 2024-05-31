-module(day14@solve).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch]).

-export([part1/1, part2/1, main/0]).

-spec parse(binary()) -> list(list(binary())).
parse(Input) ->
    _pipe = Input,
    _pipe@1 = gleam@string:split(_pipe, <<"\n"/utf8>>),
    _pipe@2 = gleam@list:map(_pipe@1, fun gleam@string:to_graphemes/1),
    gleam@list:transpose(_pipe@2).

-spec roll_boulders(list(binary())) -> list(binary()).
roll_boulders(Strs) ->
    _pipe = (gleam@list:map(
        gleam@list:chunk(
            Strs,
            fun(C) -> (C =:= <<"O"/utf8>>) orelse (C =:= <<"."/utf8>>) end
        ),
        fun(Chunks) ->
            gleam@list:sort(
                Chunks,
                gleam@order:reverse(fun gleam@string:compare/2)
            )
        end
    )),
    gleam@list:flatten(_pipe).

-spec score(list(list(binary()))) -> integer().
score(Matrix) ->
    gleam@list:fold(
        Matrix,
        0,
        fun(Acc, Col) ->
            Acc + (gleam@list:index_fold(
                gleam@list:reverse(Col),
                0,
                fun(Col_acc, Char, N) -> case Char of
                        <<"O"/utf8>> ->
                            (Col_acc + N) + 1;

                        _ ->
                            Col_acc
                    end end
            ))
        end
    ).

-spec part1(binary()) -> binary().
part1(Input) ->
    _pipe = Input,
    _pipe@1 = parse(_pipe),
    _pipe@2 = gleam@list:map(_pipe@1, fun roll_boulders/1),
    _pipe@3 = score(_pipe@2),
    gleam@string:inspect(_pipe@3).

-spec rotate(list(list(BEG))) -> list(list(BEG)).
rotate(Matrix) ->
    _pipe = Matrix,
    _pipe@1 = gleam@list:map(_pipe, fun gleam@list:reverse/1),
    gleam@list:transpose(_pipe@1).

-spec spin(list(list(binary()))) -> list(list(binary())).
spin(Matrix) ->
    gleam@list:fold(gleam@list:range(1, 4), Matrix, fun(Acc, _) -> _pipe = Acc,
            _pipe@1 = gleam@list:map(_pipe, fun roll_boulders/1),
            rotate(_pipe@1) end).

-spec check_if_seen(
    list(list(binary())),
    gleam@dict:dict(list(list(binary())), integer()),
    integer()
) -> integer().
check_if_seen(Matrix, Cache, Count) ->
    case gleam@dict:get(Cache, Matrix) of
        {error, nil} ->
            check_if_seen(
                spin(Matrix),
                gleam@dict:insert(Cache, Matrix, Count),
                Count - 1
            );

        {ok, N} ->
            _assert_subject = gleam@int:modulo(Count, N - Count),
            {ok, Extra} = case _assert_subject of
                {ok, _} -> _assert_subject;
                _assert_fail ->
                    erlang:error(#{gleam_error => let_assert,
                                message => <<"Assertion pattern match failed"/utf8>>,
                                value => _assert_fail,
                                module => <<"day14/solve"/utf8>>,
                                function => <<"check_if_seen"/utf8>>,
                                line => 67})
            end,
            _pipe = gleam@list:fold(
                gleam@list:range(1, Extra),
                Matrix,
                fun(Acc, _) -> spin(Acc) end
            ),
            score(_pipe)
    end.

-spec spin_cycle(list(list(binary()))) -> integer().
spin_cycle(Matrix) ->
    Cache = gleam@dict:new(),
    check_if_seen(Matrix, Cache, 1000000000).

-spec part2(binary()) -> binary().
part2(Input) ->
    _pipe = Input,
    _pipe@1 = parse(_pipe),
    _pipe@2 = spin_cycle(_pipe@1),
    gleam@string:inspect(_pipe@2).

-spec main() -> nil.
main() ->
    _assert_subject = adglent:get_part(),
    {ok, Part} = case _assert_subject of
        {ok, _} -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail,
                        module => <<"day14/solve"/utf8>>,
                        function => <<"main"/utf8>>,
                        line => 82})
    end,
    _assert_subject@1 = adglent:get_input(<<"14"/utf8>>),
    {ok, Input} = case _assert_subject@1 of
        {ok, _} -> _assert_subject@1;
        _assert_fail@1 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail@1,
                        module => <<"day14/solve"/utf8>>,
                        function => <<"main"/utf8>>,
                        line => 83})
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

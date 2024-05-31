-module(day2@solve).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch]).

-export([part1/1, part2/1, main/0]).
-export_type([game/0]).

-type game() :: {game, integer(), integer(), integer()}.

-spec parse(binary()) -> list(list(game())).
parse(Input) ->
    gleam@list:map(
        gleam@string:split(Input, <<"\n"/utf8>>),
        fun(Line) ->
            _assert_subject = gleam@string:split(Line, <<": "/utf8>>),
            [_, Rounds] = case _assert_subject of
                [_, _] -> _assert_subject;
                _assert_fail ->
                    erlang:error(#{gleam_error => let_assert,
                                message => <<"Assertion pattern match failed"/utf8>>,
                                value => _assert_fail,
                                module => <<"day2/solve"/utf8>>,
                                function => <<"parse"/utf8>>,
                                line => 13})
            end,
            gleam@list:map(
                gleam@string:split(Rounds, <<"; "/utf8>>),
                fun(Match) ->
                    gleam@list:fold(
                        gleam@string:split(Match, <<", "/utf8>>),
                        {game, 0, 0, 0},
                        fun(Acc, Draw) ->
                            _assert_subject@1 = gleam@string:split_once(
                                Draw,
                                <<" "/utf8>>
                            ),
                            {ok, {N_str, Color}} = case _assert_subject@1 of
                                {ok, {_, _}} -> _assert_subject@1;
                                _assert_fail@1 ->
                                    erlang:error(#{gleam_error => let_assert,
                                                message => <<"Assertion pattern match failed"/utf8>>,
                                                value => _assert_fail@1,
                                                module => <<"day2/solve"/utf8>>,
                                                function => <<"parse"/utf8>>,
                                                line => 19})
                            end,
                            _assert_subject@2 = gleam@int:parse(N_str),
                            {ok, N} = case _assert_subject@2 of
                                {ok, _} -> _assert_subject@2;
                                _assert_fail@2 ->
                                    erlang:error(#{gleam_error => let_assert,
                                                message => <<"Assertion pattern match failed"/utf8>>,
                                                value => _assert_fail@2,
                                                module => <<"day2/solve"/utf8>>,
                                                function => <<"parse"/utf8>>,
                                                line => 20})
                            end,
                            case Color of
                                <<"red"/utf8>> ->
                                    erlang:setelement(2, Acc, N);

                                <<"blue"/utf8>> ->
                                    erlang:setelement(3, Acc, N);

                                <<"green"/utf8>> ->
                                    erlang:setelement(4, Acc, N);

                                _ ->
                                    erlang:error(#{gleam_error => panic,
                                            message => <<"unrecognized color"/utf8>>,
                                            module => <<"day2/solve"/utf8>>,
                                            function => <<"parse"/utf8>>,
                                            line => 25})
                            end
                        end
                    )
                end
            )
        end
    ).

-spec part1(binary()) -> integer().
part1(Input) ->
    gleam@list:index_fold(
        parse(Input),
        0,
        fun(Acc, Game, I) ->
            case gleam@list:any(
                Game,
                fun(M) ->
                    ((erlang:element(2, M) > 12) orelse (erlang:element(4, M) > 13))
                    orelse (erlang:element(3, M) > 14)
                end
            ) of
                false ->
                    (Acc + I) + 1;

                true ->
                    Acc
            end
        end
    ).

-spec part2(binary()) -> integer().
part2(Input) ->
    _pipe = (gleam@list:map(
        parse(Input),
        fun(Game) ->
            gleam@list:fold(
                Game,
                {game, 0, 0, 0},
                fun(Acc, Match) ->
                    {game, Red, Blue, Green} = Match,
                    {game,
                        gleam@int:max(Red, erlang:element(2, Acc)),
                        gleam@int:max(Blue, erlang:element(3, Acc)),
                        gleam@int:max(Green, erlang:element(4, Acc))}
                end
            )
        end
    )),
    gleam@list:fold(
        _pipe,
        0,
        fun(Acc@1, G) ->
            Acc@1 + ((erlang:element(2, G) * erlang:element(3, G)) * erlang:element(
                4,
                G
            ))
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
                        module => <<"day2/solve"/utf8>>,
                        function => <<"main"/utf8>>,
                        line => 54})
    end,
    _assert_subject@1 = adglent:get_input(<<"2"/utf8>>),
    {ok, Input} = case _assert_subject@1 of
        {ok, _} -> _assert_subject@1;
        _assert_fail@1 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail@1,
                        module => <<"day2/solve"/utf8>>,
                        function => <<"main"/utf8>>,
                        line => 55})
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

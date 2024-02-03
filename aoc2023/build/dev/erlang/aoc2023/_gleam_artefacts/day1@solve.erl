-module(day1@solve).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function]).

-export([part1/1, part2/1, main/0]).

-spec part1(binary()) -> binary().
part1(Input) ->
    _assert_subject = gleam@regex:from_string(<<"[1-9]"/utf8>>),
    {ok, Re} = case _assert_subject of
        {ok, _} -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail,
                        module => <<"day1/solve"/utf8>>,
                        function => <<"part1"/utf8>>,
                        line => 9})
    end,
    _pipe = Input,
    _pipe@1 = gleam@string:split(_pipe, <<"\n"/utf8>>),
    _pipe@2 = gleam@list:fold(
        _pipe@1,
        0,
        fun(Acc, S) ->
            Matches = gleam@regex:scan(Re, S),
            _assert_subject@1 = gleam@list:first(Matches),
            {ok, {match, First, _}} = case _assert_subject@1 of
                {ok, {match, _, _}} -> _assert_subject@1;
                _assert_fail@1 ->
                    erlang:error(#{gleam_error => let_assert,
                                message => <<"Assertion pattern match failed"/utf8>>,
                                value => _assert_fail@1,
                                module => <<"day1/solve"/utf8>>,
                                function => <<"part1"/utf8>>,
                                line => 18})
            end,
            _assert_subject@2 = gleam@list:last(Matches),
            {ok, {match, Last, _}} = case _assert_subject@2 of
                {ok, {match, _, _}} -> _assert_subject@2;
                _assert_fail@2 ->
                    erlang:error(#{gleam_error => let_assert,
                                message => <<"Assertion pattern match failed"/utf8>>,
                                value => _assert_fail@2,
                                module => <<"day1/solve"/utf8>>,
                                function => <<"part1"/utf8>>,
                                line => 19})
            end,
            _assert_subject@3 = gleam@int:parse(<<First/binary, Last/binary>>),
            {ok, I} = case _assert_subject@3 of
                {ok, _} -> _assert_subject@3;
                _assert_fail@3 ->
                    erlang:error(#{gleam_error => let_assert,
                                message => <<"Assertion pattern match failed"/utf8>>,
                                value => _assert_fail@3,
                                module => <<"day1/solve"/utf8>>,
                                function => <<"part1"/utf8>>,
                                line => 20})
            end,
            Acc + I
        end
    ),
    gleam@string:inspect(_pipe@2).

-spec part2(binary()) -> binary().
part2(Input) ->
    _pipe = gleam@list:fold(
        [{<<"one"/utf8>>, <<"o1e"/utf8>>},
            {<<"two"/utf8>>, <<"t2o"/utf8>>},
            {<<"three"/utf8>>, <<"t3e"/utf8>>},
            {<<"four"/utf8>>, <<"4"/utf8>>},
            {<<"five"/utf8>>, <<"5e"/utf8>>},
            {<<"six"/utf8>>, <<"6"/utf8>>},
            {<<"seven"/utf8>>, <<"7n"/utf8>>},
            {<<"eight"/utf8>>, <<"e8t"/utf8>>},
            {<<"nine"/utf8>>, <<"n9e"/utf8>>}],
        Input,
        fun(Acc, Sub) ->
            {From, To} = Sub,
            gleam@string:replace(Acc, From, To)
        end
    ),
    part1(_pipe).

-spec main() -> nil.
main() ->
    _assert_subject = adglent:get_part(),
    {ok, Part} = case _assert_subject of
        {ok, _} -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail,
                        module => <<"day1/solve"/utf8>>,
                        function => <<"main"/utf8>>,
                        line => 52})
    end,
    _assert_subject@1 = adglent:get_input(<<"1"/utf8>>),
    {ok, Input} = case _assert_subject@1 of
        {ok, _} -> _assert_subject@1;
        _assert_fail@1 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail@1,
                        module => <<"day1/solve"/utf8>>,
                        function => <<"main"/utf8>>,
                        line => 53})
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

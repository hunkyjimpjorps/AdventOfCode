-module(day12@solve).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function]).

-export([part1/1, part2/1, main/0]).

-spec parse_folds(binary(), integer()) -> list({binary(), list(integer())}).
parse_folds(Input, Folds) ->
    Records = gleam@string:split(Input, <<"\n"/utf8>>),
    gleam@list:map(
        Records,
        fun(Record) ->
            _assert_subject = gleam@string:split_once(Record, <<" "/utf8>>),
            {ok, {Template, Sets_str}} = case _assert_subject of
                {ok, {_, _}} -> _assert_subject;
                _assert_fail ->
                    erlang:error(#{gleam_error => let_assert,
                                message => <<"Assertion pattern match failed"/utf8>>,
                                value => _assert_fail,
                                module => <<"day12/solve"/utf8>>,
                                function => <<"parse_folds"/utf8>>,
                                line => 15})
            end,
            Template@1 = begin
                _pipe = Template,
                _pipe@1 = gleam@list:repeat(_pipe, Folds),
                _pipe@2 = gleam@list:intersperse(_pipe@1, <<"?"/utf8>>),
                gleam@string:concat(_pipe@2)
            end,
            Sets = begin
                _pipe@3 = Sets_str,
                _pipe@4 = gleam@string:split(_pipe@3, <<","/utf8>>),
                _pipe@5 = gleam@list:map(_pipe@4, fun gleam@int:parse/1),
                _pipe@6 = gleam@result:values(_pipe@5),
                _pipe@7 = gleam@list:repeat(_pipe@6, Folds),
                gleam@list:flatten(_pipe@7)
            end,
            {Template@1, Sets}
        end
    ).

-spec do_count(
    binary(),
    list(integer()),
    integer(),
    boolean(),
    utilities@memo:cache({binary(), list(integer()), integer(), boolean()}, integer())
) -> integer().
do_count(Template, Groups, Left, Gap, Cache) ->
    utilities@memo:memoize(
        Cache,
        {Template, Groups, Left, Gap},
        fun() -> case {Template, Groups, Left, Gap} of
                {<<""/utf8>>, [], 0, _} ->
                    1;

                {<<"?"/utf8, T_rest/binary>>, [G | G_rest], 0, false} ->
                    do_count(T_rest, G_rest, G - 1, G =:= 1, Cache) + (do_count(
                        T_rest,
                        Groups,
                        0,
                        false,
                        Cache
                    ));

                {<<"?"/utf8, T_rest@1/binary>>, [], 0, false} ->
                    do_count(T_rest@1, Groups, 0, false, Cache);

                {<<"?"/utf8, T_rest@1/binary>>, _, 0, true} ->
                    do_count(T_rest@1, Groups, 0, false, Cache);

                {<<"."/utf8, T_rest@1/binary>>, _, 0, _} ->
                    do_count(T_rest@1, Groups, 0, false, Cache);

                {<<"#"/utf8, T_rest@2/binary>>, [G@1 | G_rest@1], 0, false} ->
                    do_count(T_rest@2, G_rest@1, G@1 - 1, G@1 =:= 1, Cache);

                {<<"?"/utf8, T_rest@3/binary>>, Gs, L, false} ->
                    do_count(T_rest@3, Gs, L - 1, L =:= 1, Cache);

                {<<"#"/utf8, T_rest@3/binary>>, Gs, L, false} ->
                    do_count(T_rest@3, Gs, L - 1, L =:= 1, Cache);

                {_, _, _, _} ->
                    0
            end end
    ).

-spec count_solutions(integer(), {binary(), list(integer())}) -> integer().
count_solutions(Acc, Condition) ->
    utilities@memo:create(
        fun(Cache) ->
            {Template, Groups} = Condition,
            Acc + do_count(Template, Groups, 0, false, Cache)
        end
    ).

-spec part1(binary()) -> binary().
part1(Input) ->
    _pipe = Input,
    _pipe@1 = parse_folds(_pipe, 1),
    _pipe@2 = gleam@list:fold(_pipe@1, 0, fun count_solutions/2),
    gleam@string:inspect(_pipe@2).

-spec part2(binary()) -> binary().
part2(Input) ->
    _pipe = Input,
    _pipe@1 = parse_folds(_pipe, 5),
    _pipe@2 = gleam@list:fold(_pipe@1, 0, fun count_solutions/2),
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
                        module => <<"day12/solve"/utf8>>,
                        function => <<"main"/utf8>>,
                        line => 79})
    end,
    _assert_subject@1 = adglent:get_input(<<"12"/utf8>>),
    {ok, Input} = case _assert_subject@1 of
        {ok, _} -> _assert_subject@1;
        _assert_fail@1 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail@1,
                        module => <<"day12/solve"/utf8>>,
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

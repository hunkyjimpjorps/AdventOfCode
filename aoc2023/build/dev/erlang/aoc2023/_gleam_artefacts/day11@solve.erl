-module(day11@solve).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch]).

-export([part1/1, part2/1, main/0]).
-export_type([posn/0]).

-type posn() :: {posn, integer(), integer()}.

-spec find_empty(list(list(binary()))) -> list(integer()).
find_empty(Grid) ->
    gleam@list:index_fold(
        Grid,
        [],
        fun(Acc, Row, R) -> case gleam@list:unique(Row) of
                [<<"."/utf8>>] ->
                    [R | Acc];

                _ ->
                    Acc
            end end
    ).

-spec count_prior_empty_ranks(integer(), list(integer())) -> integer().
count_prior_empty_ranks(Rank, Empty_ranks) ->
    _pipe = Empty_ranks,
    _pipe@1 = gleam@list:drop_while(_pipe, fun(R_empty) -> R_empty > Rank end),
    gleam@list:length(_pipe@1).

-spec parse_with_expansion(binary(), integer()) -> list(posn()).
parse_with_expansion(Input, Expansion) ->
    Add = Expansion - 1,
    Grid = begin
        _pipe = Input,
        _pipe@1 = gleam@string:split(_pipe, <<"\n"/utf8>>),
        gleam@list:map(_pipe@1, fun gleam@string:to_graphemes/1)
    end,
    Empty_row_list = find_empty(Grid),
    Empty_col_list = find_empty(gleam@list:transpose(Grid)),
    _pipe@2 = (gleam@list:index_map(
        Grid,
        fun(R, Row) ->
            gleam@list:index_fold(
                Row,
                [],
                fun(Acc, Cell, C) ->
                    P = {posn, R, C},
                    Empty_r = count_prior_empty_ranks(R, Empty_row_list),
                    Empty_c = count_prior_empty_ranks(C, Empty_col_list),
                    case Cell of
                        <<"#"/utf8>> ->
                            [{posn,
                                    erlang:element(2, P) + (Empty_r * Add),
                                    erlang:element(3, P) + (Empty_c * Add)} |
                                Acc];

                        _ ->
                            Acc
                    end
                end
            )
        end
    )),
    gleam@list:flatten(_pipe@2).

-spec all_distances(list(posn())) -> integer().
all_distances(Stars) ->
    gleam@list:fold(
        gleam@list:combination_pairs(Stars),
        0,
        fun(Acc, Pair) ->
            {S1, S2} = Pair,
            (Acc + gleam@int:absolute_value(
                erlang:element(2, S1) - erlang:element(2, S2)
            ))
            + gleam@int:absolute_value(
                erlang:element(3, S1) - erlang:element(3, S2)
            )
        end
    ).

-spec find_distances(binary(), integer()) -> binary().
find_distances(Input, Expand_by) ->
    _pipe = Input,
    _pipe@1 = parse_with_expansion(_pipe, Expand_by),
    _pipe@2 = all_distances(_pipe@1),
    gleam@string:inspect(_pipe@2).

-spec part1(binary()) -> binary().
part1(Input) ->
    find_distances(Input, 2).

-spec part2(binary()) -> binary().
part2(Input) ->
    find_distances(Input, 1000000).

-spec main() -> nil.
main() ->
    _assert_subject = adglent:get_part(),
    {ok, Part} = case _assert_subject of
        {ok, _} -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail,
                        module => <<"day11/solve"/utf8>>,
                        function => <<"main"/utf8>>,
                        line => 72})
    end,
    _assert_subject@1 = adglent:get_input(<<"11"/utf8>>),
    {ok, Input} = case _assert_subject@1 of
        {ok, _} -> _assert_subject@1;
        _assert_fail@1 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail@1,
                        module => <<"day11/solve"/utf8>>,
                        function => <<"main"/utf8>>,
                        line => 73})
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

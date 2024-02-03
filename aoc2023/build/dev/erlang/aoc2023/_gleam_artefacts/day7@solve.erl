-module(day7@solve).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function]).

-export([part1/1, part2/1, main/0]).
-export_type([hand/0]).

-type hand() :: {hand, list(integer()), integer()}.

-spec card_counts(hand()) -> list(integer()).
card_counts(Hand) ->
    _pipe = erlang:element(2, Hand),
    _pipe@1 = gleam@list:sort(_pipe, fun gleam@int:compare/2),
    _pipe@2 = gleam@list:chunk(_pipe@1, fun gleam@function:identity/1),
    _pipe@3 = gleam@list:map(_pipe@2, fun gleam@list:length/1),
    gleam@list:sort(_pipe@3, fun gleam@int:compare/2).

-spec classify_hand(hand()) -> integer().
classify_hand(Hand) ->
    case {gleam@list:length(gleam@list:unique(erlang:element(2, Hand))),
        card_counts(Hand)} of
        {1, _} ->
            8;

        {2, [1, 4]} ->
            7;

        {2, [2, 3]} ->
            6;

        {3, [1, 1, 3]} ->
            5;

        {3, [1, 2, 2]} ->
            4;

        {4, _} ->
            3;

        {5, _} ->
            2;

        {_, _} ->
            1
    end.

-spec card_rank(binary()) -> integer().
card_rank(Card) ->
    case {gleam@int:parse(Card), Card} of
        {{ok, N}, _} ->
            N;

        {_, <<"A"/utf8>>} ->
            14;

        {_, <<"K"/utf8>>} ->
            13;

        {_, <<"Q"/utf8>>} ->
            12;

        {_, <<"J"/utf8>>} ->
            11;

        {_, <<"T"/utf8>>} ->
            10;

        {_, _} ->
            1
    end.

-spec parse_hand(binary()) -> hand().
parse_hand(Str) ->
    _assert_subject = gleam@string:split(Str, <<" "/utf8>>),
    [Cards, Wager] = case _assert_subject of
        [_, _] -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail,
                        module => <<"day7/solve"/utf8>>,
                        function => <<"parse_hand"/utf8>>,
                        line => 19})
    end,
    Cards@1 = begin
        _pipe = gleam@string:to_graphemes(Cards),
        gleam@list:map(_pipe, fun card_rank/1)
    end,
    _assert_subject@1 = gleam@int:parse(Wager),
    {ok, Wager@1} = case _assert_subject@1 of
        {ok, _} -> _assert_subject@1;
        _assert_fail@1 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail@1,
                        module => <<"day7/solve"/utf8>>,
                        function => <<"parse_hand"/utf8>>,
                        line => 23})
    end,
    {hand, Cards@1, Wager@1}.

-spec compare_top_card(list(integer()), list(integer())) -> gleam@order:order().
compare_top_card(Cards1, Cards2) ->
    gleam@bool:guard(
        (Cards1 =:= []) orelse (Cards2 =:= []),
        eq,
        fun() ->
            [C1 | Rest1] = case Cards1 of
                [_ | _] -> Cards1;
                _assert_fail ->
                    erlang:error(#{gleam_error => let_assert,
                                message => <<"Assertion pattern match failed"/utf8>>,
                                value => _assert_fail,
                                module => <<"day7/solve"/utf8>>,
                                function => <<"compare_top_card"/utf8>>,
                                line => 70})
            end,
            [C2 | Rest2] = case Cards2 of
                [_ | _] -> Cards2;
                _assert_fail@1 ->
                    erlang:error(#{gleam_error => let_assert,
                                message => <<"Assertion pattern match failed"/utf8>>,
                                value => _assert_fail@1,
                                module => <<"day7/solve"/utf8>>,
                                function => <<"compare_top_card"/utf8>>,
                                line => 71})
            end,
            case gleam@int:compare(C1, C2) of
                eq ->
                    compare_top_card(Rest1, Rest2);

                Other ->
                    Other
            end
        end
    ).

-spec compare_hands(hand(), hand(), fun((hand()) -> integer())) -> gleam@order:order().
compare_hands(Hand1, Hand2, Using) ->
    case gleam@int:compare(Using(Hand1), Using(Hand2)) of
        eq ->
            compare_top_card(erlang:element(2, Hand1), erlang:element(2, Hand2));

        Other ->
            Other
    end.

-spec part(binary(), fun((hand(), hand()) -> gleam@order:order())) -> binary().
part(Input, Comparator) ->
    _pipe = Input,
    _pipe@1 = gleam@string:split(_pipe, <<"\n"/utf8>>),
    _pipe@2 = gleam@list:map(_pipe@1, fun parse_hand/1),
    _pipe@3 = gleam@list:sort(_pipe@2, Comparator),
    _pipe@4 = gleam@list:index_map(
        _pipe@3,
        fun(I, H) -> (I + 1) * erlang:element(3, H) end
    ),
    _pipe@5 = gleam@int:sum(_pipe@4),
    gleam@string:inspect(_pipe@5).

-spec compare_without_wilds(hand(), hand()) -> gleam@order:order().
compare_without_wilds(Hand1, Hand2) ->
    compare_hands(Hand1, Hand2, fun classify_hand/1).

-spec part1(binary()) -> binary().
part1(Input) ->
    part(Input, fun compare_without_wilds/2).

-spec find_best_joker_substitution(hand()) -> hand().
find_best_joker_substitution(Hand) ->
    gleam@list:fold(
        gleam@list:range(2, 14),
        {hand, [], 0},
        fun(Acc, Card) ->
            Subbed_cards = (gleam@list:map(
                erlang:element(2, Hand),
                fun(C) -> case C of
                        1 ->
                            Card;

                        Other ->
                            Other
                    end end
            )),
            Subbed_hand = erlang:setelement(2, Hand, Subbed_cards),
            case compare_hands(Acc, Subbed_hand, fun classify_hand/1) of
                lt ->
                    Subbed_hand;

                _ ->
                    Acc
            end
        end
    ).

-spec compare_hands_considering_jokers(hand(), hand()) -> gleam@order:order().
compare_hands_considering_jokers(Hand1, Hand2) ->
    compare_hands(Hand1, Hand2, fun(Hand) -> _pipe = Hand,
            _pipe@1 = find_best_joker_substitution(_pipe),
            classify_hand(_pipe@1) end).

-spec part2(binary()) -> binary().
part2(Input) ->
    part(
        gleam@string:replace(Input, <<"J"/utf8>>, <<"*"/utf8>>),
        fun compare_hands_considering_jokers/2
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
                        module => <<"day7/solve"/utf8>>,
                        function => <<"main"/utf8>>,
                        line => 128})
    end,
    _assert_subject@1 = adglent:get_input(<<"7"/utf8>>),
    {ok, Input} = case _assert_subject@1 of
        {ok, _} -> _assert_subject@1;
        _assert_fail@1 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail@1,
                        module => <<"day7/solve"/utf8>>,
                        function => <<"main"/utf8>>,
                        line => 129})
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

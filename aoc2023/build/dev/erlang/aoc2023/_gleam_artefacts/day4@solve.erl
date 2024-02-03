-module(day4@solve).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function]).

-export([part1/1, part2/1, main/0]).
-export_type([card/0]).

-type card() :: {card, integer(), integer()}.

-spec numbers_to_set(binary()) -> gleam@set:set(integer()).
numbers_to_set(Str) ->
    _pipe = Str,
    _pipe@1 = gleam@string:split(_pipe, <<" "/utf8>>),
    _pipe@2 = gleam@list:map(_pipe@1, fun gleam@int:parse/1),
    _pipe@3 = gleam@result:values(_pipe@2),
    gleam@set:from_list(_pipe@3).

-spec parse_card(binary()) -> card().
parse_card(Card) ->
    _assert_subject = gleam@string:split_once(Card, <<": "/utf8>>),
    {ok, {<<"Card"/utf8, N_str/binary>>, Rest}} = case _assert_subject of
        {ok, {<<"Card"/utf8, _/binary>>, _}} -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail,
                        module => <<"day4/solve"/utf8>>,
                        function => <<"parse_card"/utf8>>,
                        line => 25})
    end,
    _assert_subject@1 = gleam@string:split_once(Rest, <<" | "/utf8>>),
    {ok, {Winning_str, Has_str}} = case _assert_subject@1 of
        {ok, {_, _}} -> _assert_subject@1;
        _assert_fail@1 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail@1,
                        module => <<"day4/solve"/utf8>>,
                        function => <<"parse_card"/utf8>>,
                        line => 26})
    end,
    _assert_subject@2 = gleam@int:parse(gleam@string:trim(N_str)),
    {ok, N} = case _assert_subject@2 of
        {ok, _} -> _assert_subject@2;
        _assert_fail@2 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail@2,
                        module => <<"day4/solve"/utf8>>,
                        function => <<"parse_card"/utf8>>,
                        line => 27})
    end,
    Winning = numbers_to_set(Winning_str),
    Has = numbers_to_set(Has_str),
    Winners = gleam@set:size(gleam@set:intersection(Winning, Has)),
    {card, N, Winners}.

-spec win_points(integer()) -> integer().
win_points(N) ->
    gleam@bool:guard(N < 2, N, fun() -> 2 * win_points(N - 1) end).

-spec part1(binary()) -> integer().
part1(Input) ->
    gleam@list:fold(
        gleam@string:split(Input, <<"\n"/utf8>>),
        0,
        fun(Acc, C) -> _pipe = C,
            _pipe@1 = parse_card(_pipe),
            _pipe@2 = (fun(C@1) -> win_points(erlang:element(3, C@1)) end)(
                _pipe@1
            ),
            gleam@int:add(_pipe@2, Acc) end
    ).

-spec update_counts(integer(), card(), gleam@dict:dict(integer(), integer())) -> gleam@dict:dict(integer(), integer()).
update_counts(N, Card, Count) ->
    _assert_subject = gleam@dict:get(Count, erlang:element(2, Card)),
    {ok, Bonus} = case _assert_subject of
        {ok, _} -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail,
                        module => <<"day4/solve"/utf8>>,
                        function => <<"update_counts"/utf8>>,
                        line => 65})
    end,
    gleam@list:fold(
        gleam@list:range(
            erlang:element(2, Card) + 1,
            erlang:element(2, Card) + N
        ),
        Count,
        fun(Acc, N@1) -> gleam@dict:update(Acc, N@1, fun(C) -> case C of
                        {some, I} ->
                            I + Bonus;

                        none ->
                            erlang:error(#{gleam_error => panic,
                                    message => <<"won a card that doesn't exist in the card pile"/utf8>>,
                                    module => <<"day4/solve"/utf8>>,
                                    function => <<"update_counts"/utf8>>,
                                    line => 70})
                    end end) end
    ).

-spec win_more_cards(list(binary()), gleam@dict:dict(integer(), integer())) -> integer().
win_more_cards(Cards, Count) ->
    case Cards of
        [] ->
            _pipe = Count,
            _pipe@1 = gleam@dict:values(_pipe),
            gleam@int:sum(_pipe@1);

        [Raw_card | Rest] ->
            Card = parse_card(Raw_card),
            case erlang:element(3, Card) of
                0 ->
                    win_more_cards(Rest, Count);

                N ->
                    win_more_cards(Rest, update_counts(N, Card, Count))
            end
    end.

-spec part2(binary()) -> integer().
part2(Input) ->
    Cards = gleam@string:split(Input, <<"\n"/utf8>>),
    Count = begin
        _pipe = gleam@list:range(1, gleam@list:length(Cards)),
        _pipe@1 = gleam@list:map(_pipe, fun(N) -> {N, 1} end),
        gleam@dict:from_list(_pipe@1)
    end,
    win_more_cards(Cards, Count).

-spec main() -> nil.
main() ->
    _assert_subject = adglent:get_part(),
    {ok, Part} = case _assert_subject of
        {ok, _} -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail,
                        module => <<"day4/solve"/utf8>>,
                        function => <<"main"/utf8>>,
                        line => 86})
    end,
    _assert_subject@1 = adglent:get_input(<<"4"/utf8>>),
    {ok, Input} = case _assert_subject@1 of
        {ok, _} -> _assert_subject@1;
        _assert_fail@1 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail@1,
                        module => <<"day4/solve"/utf8>>,
                        function => <<"main"/utf8>>,
                        line => 87})
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

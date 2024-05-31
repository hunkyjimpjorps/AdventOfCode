-module(day6@solve).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch]).

-export([part1/1, part2/1, main/0]).
-export_type([race/0]).

-type race() :: {race, integer(), integer()}.

-spec parse_with_bad_kerning(binary()) -> list(race()).
parse_with_bad_kerning(Input) ->
    _pipe = Input,
    _pipe@1 = gleam@string:split(_pipe, <<"\n"/utf8>>),
    _pipe@5 = gleam@list:map(_pipe@1, fun(Str) -> _pipe@2 = Str,
            _pipe@3 = gleam@string:split(_pipe@2, <<" "/utf8>>),
            _pipe@4 = gleam@list:map(_pipe@3, fun gleam@int:parse/1),
            gleam@result:values(_pipe@4) end),
    _pipe@6 = gleam@list:transpose(_pipe@5),
    gleam@list:map(
        _pipe@6,
        fun(Ns) ->
            [T, D] = case Ns of
                [_, _] -> Ns;
                _assert_fail ->
                    erlang:error(#{gleam_error => let_assert,
                                message => <<"Assertion pattern match failed"/utf8>>,
                                value => _assert_fail,
                                module => <<"day6/solve"/utf8>>,
                                function => <<"parse_with_bad_kerning"/utf8>>,
                                line => 23})
            end,
            {race, T, D}
        end
    ).

-spec find_bound(race(), integer(), integer()) -> integer().
find_bound(Race, Button_time, Step) ->
    Travel_time = erlang:element(2, Race) - Button_time,
    case (Button_time * Travel_time) > erlang:element(3, Race) of
        true ->
            Button_time;

        false ->
            find_bound(Race, Button_time + Step, Step)
    end.

-spec lower_bound(race()) -> integer().
lower_bound(Race) ->
    find_bound(Race, 1, 1).

-spec upper_bound(race()) -> integer().
upper_bound(Race) ->
    find_bound(Race, erlang:element(2, Race), -1).

-spec part1(binary()) -> binary().
part1(Input) ->
    _pipe = (gleam@list:fold(
        parse_with_bad_kerning(Input),
        1,
        fun(Acc, Race) ->
            Acc * ((upper_bound(Race) - lower_bound(Race)) + 1)
        end
    )),
    gleam@string:inspect(_pipe).

-spec parse_properly(binary()) -> list(integer()).
parse_properly(Input) ->
    _pipe = Input,
    _pipe@1 = gleam@string:replace(_pipe, <<" "/utf8>>, <<""/utf8>>),
    _pipe@2 = gleam@string:split(_pipe@1, <<"\n"/utf8>>),
    _pipe@3 = gleam@list:flat_map(
        _pipe@2,
        fun(_capture) -> gleam@string:split(_capture, <<":"/utf8>>) end
    ),
    _pipe@4 = gleam@list:map(_pipe@3, fun gleam@int:parse/1),
    gleam@result:values(_pipe@4).

-spec part2(binary()) -> binary().
part2(Input) ->
    _assert_subject = begin
        _pipe = Input,
        parse_properly(_pipe)
    end,
    [Time, Distance] = case _assert_subject of
        [_, _] -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail,
                        module => <<"day6/solve"/utf8>>,
                        function => <<"part2"/utf8>>,
                        line => 62})
    end,
    Race = {race, Time, Distance},
    _pipe@1 = (upper_bound(Race) - lower_bound(Race)) + 1,
    gleam@string:inspect(_pipe@1).

-spec main() -> nil.
main() ->
    _assert_subject = adglent:get_part(),
    {ok, Part} = case _assert_subject of
        {ok, _} -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail,
                        module => <<"day6/solve"/utf8>>,
                        function => <<"main"/utf8>>,
                        line => 73})
    end,
    _assert_subject@1 = adglent:get_input(<<"6"/utf8>>),
    {ok, Input} = case _assert_subject@1 of
        {ok, _} -> _assert_subject@1;
        _assert_fail@1 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail@1,
                        module => <<"day6/solve"/utf8>>,
                        function => <<"main"/utf8>>,
                        line => 74})
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

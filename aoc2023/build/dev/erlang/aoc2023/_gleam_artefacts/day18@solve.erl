-module(day18@solve).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function]).

-export([part1/1, part2/1, main/0]).
-export_type([coord/0, direction/0, dig/0]).

-type coord() :: {coord, integer(), integer()}.

-type direction() :: up | right | down | left.

-type dig() :: {dig, direction(), integer()}.

-spec to_direction(binary()) -> direction().
to_direction(C) ->
    case C of
        <<"R"/utf8>> ->
            right;

        <<"0"/utf8>> ->
            right;

        <<"D"/utf8>> ->
            down;

        <<"1"/utf8>> ->
            down;

        <<"L"/utf8>> ->
            left;

        <<"2"/utf8>> ->
            left;

        <<"U"/utf8>> ->
            up;

        <<"3"/utf8>> ->
            up;

        _ ->
            erlang:error(#{gleam_error => panic,
                    message => <<"panic expression evaluated"/utf8>>,
                    module => <<"day18/solve"/utf8>>,
                    function => <<"to_direction"/utf8>>,
                    line => 30})
    end.

-spec parse_front(binary()) -> dig().
parse_front(Line) ->
    _assert_subject = gleam@regex:from_string(<<"(.) (.*) \\(.*\\)"/utf8>>),
    {ok, Re} = case _assert_subject of
        {ok, _} -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail,
                        module => <<"day18/solve"/utf8>>,
                        function => <<"parse_front"/utf8>>,
                        line => 35})
    end,
    _assert_subject@1 = gleam@regex:scan(Re, Line),
    [{match, _, [{some, Dir}, {some, Dist}]}] = case _assert_subject@1 of
        [{match, _, [{some, _}, {some, _}]}] -> _assert_subject@1;
        _assert_fail@1 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail@1,
                        module => <<"day18/solve"/utf8>>,
                        function => <<"parse_front"/utf8>>,
                        line => 36})
    end,
    _assert_subject@2 = gleam@int:parse(Dist),
    {ok, N} = case _assert_subject@2 of
        {ok, _} -> _assert_subject@2;
        _assert_fail@2 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail@2,
                        module => <<"day18/solve"/utf8>>,
                        function => <<"parse_front"/utf8>>,
                        line => 38})
    end,
    {dig, to_direction(Dir), N}.

-spec parse_hex(binary()) -> dig().
parse_hex(Line) ->
    _assert_subject = gleam@regex:from_string(<<"\\(#(.....)(.)\\)"/utf8>>),
    {ok, Re} = case _assert_subject of
        {ok, _} -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail,
                        module => <<"day18/solve"/utf8>>,
                        function => <<"parse_hex"/utf8>>,
                        line => 43})
    end,
    _assert_subject@1 = gleam@regex:scan(Re, Line),
    [{match, _, [{some, Dist}, {some, Dir}]}] = case _assert_subject@1 of
        [{match, _, [{some, _}, {some, _}]}] -> _assert_subject@1;
        _assert_fail@1 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail@1,
                        module => <<"day18/solve"/utf8>>,
                        function => <<"parse_hex"/utf8>>,
                        line => 44})
    end,
    _assert_subject@2 = gleam@int:base_parse(Dist, 16),
    {ok, N} = case _assert_subject@2 of
        {ok, _} -> _assert_subject@2;
        _assert_fail@2 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail@2,
                        module => <<"day18/solve"/utf8>>,
                        function => <<"parse_hex"/utf8>>,
                        line => 46})
    end,
    {dig, to_direction(Dir), N}.

-spec go(coord(), dig()) -> coord().
go(Current, Dig) ->
    case Dig of
        {dig, up, N} ->
            {coord, erlang:element(2, Current), erlang:element(3, Current) + N};

        {dig, right, N@1} ->
            {coord,
                erlang:element(2, Current) + N@1,
                erlang:element(3, Current)};

        {dig, down, N@2} ->
            {coord,
                erlang:element(2, Current),
                erlang:element(3, Current) - N@2};

        {dig, left, N@3} ->
            {coord,
                erlang:element(2, Current) - N@3,
                erlang:element(3, Current)}
    end.

-spec double_triangle(coord(), coord()) -> integer().
double_triangle(C1, C2) ->
    (erlang:element(2, C1) * erlang:element(3, C2)) - (erlang:element(2, C2) * erlang:element(
        3,
        C1
    )).

-spec do_next_dig(list(dig()), coord(), integer(), integer()) -> integer().
do_next_dig(Digs, Current, Area, Perimeter) ->
    case Digs of
        [] ->
            ((gleam@int:absolute_value(Area) div 2) + (Perimeter div 2)) + 1;

        [Dig | Rest] ->
            Next = go(Current, Dig),
            Area@1 = Area + double_triangle(Current, Next),
            Perimeter@1 = Perimeter + erlang:element(3, Dig),
            do_next_dig(Rest, Next, Area@1, Perimeter@1)
    end.

-spec start_dig(list(dig())) -> integer().
start_dig(Digs) ->
    do_next_dig(Digs, {coord, 0, 0}, 0, 0).

-spec solve_with(binary(), fun((binary()) -> dig())) -> binary().
solve_with(Input, F) ->
    _pipe = Input,
    _pipe@1 = gleam@string:split(_pipe, <<"\n"/utf8>>),
    _pipe@2 = gleam@list:map(_pipe@1, F),
    _pipe@3 = start_dig(_pipe@2),
    gleam@string:inspect(_pipe@3).

-spec part1(binary()) -> binary().
part1(Input) ->
    solve_with(Input, fun parse_front/1).

-spec part2(binary()) -> binary().
part2(Input) ->
    solve_with(Input, fun parse_hex/1).

-spec main() -> nil.
main() ->
    _assert_subject = adglent:get_part(),
    {ok, Part} = case _assert_subject of
        {ok, _} -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail,
                        module => <<"day18/solve"/utf8>>,
                        function => <<"main"/utf8>>,
                        line => 101})
    end,
    _assert_subject@1 = adglent:get_input(<<"18"/utf8>>),
    {ok, Input} = case _assert_subject@1 of
        {ok, _} -> _assert_subject@1;
        _assert_fail@1 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail@1,
                        module => <<"day18/solve"/utf8>>,
                        function => <<"main"/utf8>>,
                        line => 102})
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

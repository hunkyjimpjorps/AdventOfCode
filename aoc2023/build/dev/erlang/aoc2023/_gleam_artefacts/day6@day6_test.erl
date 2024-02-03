-module(day6@day6_test).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function]).

-export([part1_test/0, part2_test/0]).

-spec part1_test() -> list(nil).
part1_test() ->
    _pipe = [{example,
            <<"Time:      7  15   30
Distance:  9  40  200"/utf8>>,
            <<"288"/utf8>>}],
    showtime@tests@should:not_equal(_pipe, []),
    gleam@list:map(
        [{example,
                <<"Time:      7  15   30
Distance:  9  40  200"/utf8>>,
                <<"288"/utf8>>}],
        fun(Example) -> _pipe@1 = day6@solve:part1(erlang:element(2, Example)),
            showtime@tests@should:equal(_pipe@1, erlang:element(3, Example)) end
    ).

-spec part2_test() -> list(nil).
part2_test() ->
    _pipe = [{example,
            <<"Time:      7  15   30
Distance:  9  40  200"/utf8>>,
            <<"71503"/utf8>>}],
    showtime@tests@should:not_equal(_pipe, []),
    gleam@list:map(
        [{example,
                <<"Time:      7  15   30
Distance:  9  40  200"/utf8>>,
                <<"71503"/utf8>>}],
        fun(Example) -> _pipe@1 = day6@solve:part2(erlang:element(2, Example)),
            showtime@tests@should:equal(_pipe@1, erlang:element(3, Example)) end
    ).

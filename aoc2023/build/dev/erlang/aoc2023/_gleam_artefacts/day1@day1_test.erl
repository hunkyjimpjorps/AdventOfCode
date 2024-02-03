-module(day1@day1_test).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function]).

-export([part1_test/0, part2_test/0]).

-spec part1_test() -> list(nil).
part1_test() ->
    _pipe = [{example,
            <<"1abc2
pqr3stu8vwx
a1b2c3d4e5f
treb7uchet"/utf8>>,
            <<"142"/utf8>>}],
    showtime@tests@should:not_equal(_pipe, []),
    gleam@list:map(
        [{example,
                <<"1abc2
pqr3stu8vwx
a1b2c3d4e5f
treb7uchet"/utf8>>,
                <<"142"/utf8>>}],
        fun(Example) -> _pipe@1 = day1@solve:part1(erlang:element(2, Example)),
            showtime@tests@should:equal(_pipe@1, erlang:element(3, Example)) end
    ).

-spec part2_test() -> list(nil).
part2_test() ->
    _pipe = [{example,
            <<"two1nine
eightwothree
abcone2threexyz
xtwone3four
4nineeightseven2
zoneight234
7pqrstsixteen"/utf8>>,
            <<"281"/utf8>>}],
    showtime@tests@should:not_equal(_pipe, []),
    gleam@list:map(
        [{example,
                <<"two1nine
eightwothree
abcone2threexyz
xtwone3four
4nineeightseven2
zoneight234
7pqrstsixteen"/utf8>>,
                <<"281"/utf8>>}],
        fun(Example) -> _pipe@1 = day1@solve:part2(erlang:element(2, Example)),
            showtime@tests@should:equal(_pipe@1, erlang:element(3, Example)) end
    ).

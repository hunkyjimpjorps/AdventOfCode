-module(day9@day9_test).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch]).

-export([part1_test/0, part2_test/0]).

-spec part1_test() -> list(nil).
part1_test() ->
    _pipe = [{example,
            <<"0 3 6 9 12 15
1 3 6 10 15 21
10 13 16 21 30 45"/utf8>>,
            <<"114"/utf8>>}],
    showtime@tests@should:not_equal(_pipe, []),
    gleam@list:map(
        [{example,
                <<"0 3 6 9 12 15
1 3 6 10 15 21
10 13 16 21 30 45"/utf8>>,
                <<"114"/utf8>>}],
        fun(Example) -> _pipe@1 = day9@solve:part1(erlang:element(2, Example)),
            showtime@tests@should:equal(_pipe@1, erlang:element(3, Example)) end
    ).

-spec part2_test() -> list(nil).
part2_test() ->
    _pipe = [{example,
            <<"0 3 6 9 12 15
1 3 6 10 15 21
10 13 16 21 30 45"/utf8>>,
            <<"2"/utf8>>}],
    showtime@tests@should:not_equal(_pipe, []),
    gleam@list:map(
        [{example,
                <<"0 3 6 9 12 15
1 3 6 10 15 21
10 13 16 21 30 45"/utf8>>,
                <<"2"/utf8>>}],
        fun(Example) -> _pipe@1 = day9@solve:part2(erlang:element(2, Example)),
            showtime@tests@should:equal(_pipe@1, erlang:element(3, Example)) end
    ).

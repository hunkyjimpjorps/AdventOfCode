-module(day21@day21_test).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch]).

-export([part1_test/0, part2_test/0]).

-spec part1_test() -> list(nil).
part1_test() ->
    _pipe = [],
    showtime@tests@should:not_equal(_pipe, []),
    gleam@list:map(
        [],
        fun(Example) -> _pipe@1 = day21@solve:part1(erlang:element(2, Example)),
            showtime@tests@should:equal(_pipe@1, erlang:element(3, Example)) end
    ).

-spec part2_test() -> list(nil).
part2_test() ->
    _pipe = [],
    showtime@tests@should:not_equal(_pipe, []),
    gleam@list:map(
        [],
        fun(Example) -> _pipe@1 = day21@solve:part2(erlang:element(2, Example)),
            showtime@tests@should:equal(_pipe@1, erlang:element(3, Example)) end
    ).

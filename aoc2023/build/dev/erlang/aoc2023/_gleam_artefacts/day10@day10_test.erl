-module(day10@day10_test).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function]).

-export([part1_test/0, part2_test/0]).

-spec part1_test() -> list(nil).
part1_test() ->
    _pipe = [{example, <<"7-F7-
.FJ|7
SJLL7
|F--J
LJ.LJ"/utf8>>, <<"8"/utf8>>}],
    showtime@tests@should:not_equal(_pipe, []),
    gleam@list:map(
        [{example, <<"7-F7-
.FJ|7
SJLL7
|F--J
LJ.LJ"/utf8>>, <<"8"/utf8>>}],
        fun(Example) -> _pipe@1 = day10@solve:part1(erlang:element(2, Example)),
            showtime@tests@should:equal(_pipe@1, erlang:element(3, Example)) end
    ).

-spec part2_test() -> list(nil).
part2_test() ->
    _pipe = [{example,
            <<"...........
.S-------7.
.|F-----7|.
.||OOOOO||.
.||OOOOO||.
.|L-7OF-J|.
.|II|O|II|.
.L--JOL--J.
.....O....."/utf8>>,
            <<"4"/utf8>>}],
    showtime@tests@should:not_equal(_pipe, []),
    gleam@list:map(
        [{example,
                <<"...........
.S-------7.
.|F-----7|.
.||OOOOO||.
.||OOOOO||.
.|L-7OF-J|.
.|II|O|II|.
.L--JOL--J.
.....O....."/utf8>>,
                <<"4"/utf8>>}],
        fun(Example) -> _pipe@1 = day10@solve:part2(erlang:element(2, Example)),
            showtime@tests@should:equal(_pipe@1, erlang:element(3, Example)) end
    ).

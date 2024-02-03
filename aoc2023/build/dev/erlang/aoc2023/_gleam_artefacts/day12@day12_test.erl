-module(day12@day12_test).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function]).

-export([part1_test/0, part2_test/0]).

-spec part1_test() -> list(nil).
part1_test() ->
    _pipe = [{example,
            <<"???.### 1,1,3
.??..??...?##. 1,1,3
?#?#?#?#?#?#?#? 1,3,1,6
????.#...#... 4,1,1
????.######..#####. 1,6,5
?###???????? 3,2,1"/utf8>>,
            <<"21"/utf8>>}],
    showtime@tests@should:not_equal(_pipe, []),
    gleam@list:map(
        [{example,
                <<"???.### 1,1,3
.??..??...?##. 1,1,3
?#?#?#?#?#?#?#? 1,3,1,6
????.#...#... 4,1,1
????.######..#####. 1,6,5
?###???????? 3,2,1"/utf8>>,
                <<"21"/utf8>>}],
        fun(Example) -> _pipe@1 = day12@solve:part1(erlang:element(2, Example)),
            showtime@tests@should:equal(_pipe@1, erlang:element(3, Example)) end
    ).

-spec part2_test() -> list(nil).
part2_test() ->
    _pipe = [],
    showtime@tests@should:not_equal(_pipe, []),
    gleam@list:map(
        [],
        fun(Example) -> _pipe@1 = day12@solve:part2(erlang:element(2, Example)),
            showtime@tests@should:equal(_pipe@1, erlang:element(3, Example)) end
    ).

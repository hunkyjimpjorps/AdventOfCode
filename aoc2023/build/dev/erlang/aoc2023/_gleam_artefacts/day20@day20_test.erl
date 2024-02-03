-module(day20@day20_test).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function]).

-export([part1_test/0, part2_test/0]).

-spec part1_test() -> list(nil).
part1_test() ->
    _pipe = [{example,
            <<"broadcaster -> a, b, c
%a -> b
%b -> c
%c -> inv
&inv -> a"/utf8>>,
            <<"32000000"/utf8>>},
        {example,
            <<"broadcaster -> a
%a -> inv, con
&inv -> b
%b -> con
&con -> output
output -> "/utf8>>,
            <<"11687500"/utf8>>}],
    showtime@tests@should:not_equal(_pipe, []),
    gleam@list:map(
        [{example,
                <<"broadcaster -> a, b, c
%a -> b
%b -> c
%c -> inv
&inv -> a"/utf8>>,
                <<"32000000"/utf8>>},
            {example,
                <<"broadcaster -> a
%a -> inv, con
&inv -> b
%b -> con
&con -> output
output -> "/utf8>>,
                <<"11687500"/utf8>>}],
        fun(Example) -> _pipe@1 = day20@solve:part1(erlang:element(2, Example)),
            showtime@tests@should:equal(_pipe@1, erlang:element(3, Example)) end
    ).

-spec part2_test() -> list(nil).
part2_test() ->
    _pipe = [],
    showtime@tests@should:not_equal(_pipe, []),
    gleam@list:map(
        [],
        fun(Example) -> _pipe@1 = day20@solve:part2(erlang:element(2, Example)),
            showtime@tests@should:equal(_pipe@1, erlang:element(3, Example)) end
    ).

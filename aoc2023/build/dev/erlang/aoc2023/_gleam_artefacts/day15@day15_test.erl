-module(day15@day15_test).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function]).

-export([part1_test/0, part2_test/0]).

-spec part1_test() -> list(nil).
part1_test() ->
    _pipe = [{example,
            <<"rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7"/utf8>>,
            <<"1320"/utf8>>}],
    showtime@tests@should:not_equal(_pipe, []),
    gleam@list:map(
        [{example,
                <<"rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7"/utf8>>,
                <<"1320"/utf8>>}],
        fun(Example) -> _pipe@1 = day15@solve:part1(erlang:element(2, Example)),
            showtime@tests@should:equal(_pipe@1, erlang:element(3, Example)) end
    ).

-spec part2_test() -> list(nil).
part2_test() ->
    _pipe = [{example,
            <<"rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7"/utf8>>,
            <<"145"/utf8>>}],
    showtime@tests@should:not_equal(_pipe, []),
    gleam@list:map(
        [{example,
                <<"rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7"/utf8>>,
                <<"145"/utf8>>}],
        fun(Example) -> _pipe@1 = day15@solve:part2(erlang:element(2, Example)),
            showtime@tests@should:equal(_pipe@1, erlang:element(3, Example)) end
    ).

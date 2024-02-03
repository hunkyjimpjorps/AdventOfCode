-module(day5@day5_test).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function]).

-export([part1_test/0, part2_test/0]).

-spec part1_test() -> list(nil).
part1_test() ->
    _pipe = [{example,
            <<"seeds: 79 14 55 13

seed-to-soil map:
50 98 2
52 50 48

soil-to-fertilizer map:
0 15 37
37 52 2
39 0 15

fertilizer-to-water map:
49 53 8
0 11 42
42 0 7
57 7 4

water-to-light map:
88 18 7
18 25 70

light-to-temperature map:
45 77 23
81 45 19
68 64 13

temperature-to-humidity map:
0 69 1
1 0 69

humidity-to-location map:
60 56 37
56 93 4"/utf8>>,
            <<"35"/utf8>>}],
    showtime@tests@should:not_equal(_pipe, []),
    gleam@list:map(
        [{example,
                <<"seeds: 79 14 55 13

seed-to-soil map:
50 98 2
52 50 48

soil-to-fertilizer map:
0 15 37
37 52 2
39 0 15

fertilizer-to-water map:
49 53 8
0 11 42
42 0 7
57 7 4

water-to-light map:
88 18 7
18 25 70

light-to-temperature map:
45 77 23
81 45 19
68 64 13

temperature-to-humidity map:
0 69 1
1 0 69

humidity-to-location map:
60 56 37
56 93 4"/utf8>>,
                <<"35"/utf8>>}],
        fun(Example) -> _pipe@1 = day5@solve:part1(erlang:element(2, Example)),
            showtime@tests@should:equal(_pipe@1, erlang:element(3, Example)) end
    ).

-spec part2_test() -> list(nil).
part2_test() ->
    _pipe = [{example,
            <<"seeds: 79 14 55 13

seed-to-soil map:
50 98 2
52 50 48

soil-to-fertilizer map:
0 15 37
37 52 2
39 0 15

fertilizer-to-water map:
49 53 8
0 11 42
42 0 7
57 7 4

water-to-light map:
88 18 7
18 25 70

light-to-temperature map:
45 77 23
81 45 19
68 64 13

temperature-to-humidity map:
0 69 1
1 0 69

humidity-to-location map:
60 56 37
56 93 4"/utf8>>,
            <<"46"/utf8>>}],
    showtime@tests@should:not_equal(_pipe, []),
    gleam@list:map(
        [{example,
                <<"seeds: 79 14 55 13

seed-to-soil map:
50 98 2
52 50 48

soil-to-fertilizer map:
0 15 37
37 52 2
39 0 15

fertilizer-to-water map:
49 53 8
0 11 42
42 0 7
57 7 4

water-to-light map:
88 18 7
18 25 70

light-to-temperature map:
45 77 23
81 45 19
68 64 13

temperature-to-humidity map:
0 69 1
1 0 69

humidity-to-location map:
60 56 37
56 93 4"/utf8>>,
                <<"46"/utf8>>}],
        fun(Example) -> _pipe@1 = day5@solve:part2(erlang:element(2, Example)),
            showtime@tests@should:equal(_pipe@1, erlang:element(3, Example)) end
    ).

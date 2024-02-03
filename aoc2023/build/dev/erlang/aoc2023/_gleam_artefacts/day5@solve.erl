-module(day5@solve).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function]).

-export([part1/1, part2/1, main/0]).
-export_type([almanac/0, mapping_range/0, seed_range/0]).

-type almanac() :: {almanac, list(integer()), list(list(mapping_range()))}.

-type mapping_range() :: {m_range, integer(), integer(), integer()}.

-type seed_range() :: {s_range, integer(), integer()}.

-spec string_to_int_list(binary()) -> list(integer()).
string_to_int_list(Str) ->
    _pipe = Str,
    _pipe@1 = gleam@string:split(_pipe, <<" "/utf8>>),
    _pipe@2 = gleam@list:map(_pipe@1, fun gleam@int:parse/1),
    gleam@result:values(_pipe@2).

-spec parse_mrange(binary()) -> mapping_range().
parse_mrange(Str) ->
    _assert_subject = string_to_int_list(Str),
    [Destination, Source, Range_width] = case _assert_subject of
        [_, _, _] -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail,
                        module => <<"day5/solve"/utf8>>,
                        function => <<"parse_mrange"/utf8>>,
                        line => 55})
    end,
    {m_range, Source, (Source + Range_width) - 1, Destination - Source}.

-spec parse_mapper(list(binary())) -> list(mapping_range()).
parse_mapper(Strs) ->
    [_ | Raw_ranges] = case Strs of
        [_ | _] -> Strs;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail,
                        module => <<"day5/solve"/utf8>>,
                        function => <<"parse_mapper"/utf8>>,
                        line => 49})
    end,
    _pipe = gleam@list:map(Raw_ranges, fun parse_mrange/1),
    gleam@list:sort(
        _pipe,
        fun(A, B) ->
            gleam@int:compare(erlang:element(2, A), erlang:element(2, B))
        end
    ).

-spec parse_input(binary()) -> almanac().
parse_input(Input) ->
    _assert_subject = gleam@string:split(Input, <<"\n\n"/utf8>>),
    [<<"seeds: "/utf8, Raw_seeds/binary>> | Raw_mappers] = case _assert_subject of
        [<<"seeds: "/utf8, _/binary>> | _] -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail,
                        module => <<"day5/solve"/utf8>>,
                        function => <<"parse_input"/utf8>>,
                        line => 29})
    end,
    Seeds = string_to_int_list(Raw_seeds),
    Mappers = gleam@list:map(
        Raw_mappers,
        gleam@function:compose(
            fun(_capture) -> gleam@string:split(_capture, <<"\n"/utf8>>) end,
            fun parse_mapper/1
        )
    ),
    {almanac, Seeds, Mappers}.

-spec correspond(integer(), list(mapping_range())) -> integer().
correspond(N, Mapper) ->
    gleam@list:fold_until(
        Mapper,
        N,
        fun(Acc, Mrange) ->
            case (erlang:element(2, Mrange) =< Acc) andalso (Acc =< erlang:element(
                3,
                Mrange
            )) of
                true ->
                    {stop, Acc + erlang:element(4, Mrange)};

                false ->
                    {continue, Acc}
            end
        end
    ).

-spec part1(binary()) -> binary().
part1(Input) ->
    {almanac, Seeds, Mappers} = parse_input(Input),
    _pipe = gleam@list:map(
        Seeds,
        fun(_capture) ->
            gleam@list:fold(Mappers, _capture, fun correspond/2)
        end
    ),
    _pipe@1 = gleam@list:reduce(_pipe, fun gleam@int:min/2),
    _pipe@2 = gleam@result:unwrap(_pipe@1, 0),
    gleam@string:inspect(_pipe@2).

-spec transform_range(seed_range(), mapping_range()) -> seed_range().
transform_range(R, Mapper) ->
    {s_range,
        erlang:element(2, R) + erlang:element(4, Mapper),
        erlang:element(3, R) + erlang:element(4, Mapper)}.

-spec do_remap_range(seed_range(), list(mapping_range()), list(seed_range())) -> list(seed_range()).
do_remap_range(R, Mapper, Acc) ->
    case Mapper of
        [] ->
            [R | Acc];

        [M | _] when erlang:element(3, R) < erlang:element(2, M) ->
            [R | Acc];

        [M@1 | Ms] when erlang:element(2, R) > erlang:element(3, M@1) ->
            do_remap_range(R, Ms, Acc);

        [M@2 | _] when (erlang:element(2, R) >= erlang:element(2, M@2)) andalso (erlang:element(
            3,
            R
        ) =< erlang:element(3, M@2)) ->
            [transform_range(R, M@2) | Acc];

        [M@3 | _] when (erlang:element(2, R) < erlang:element(2, M@3)) andalso (erlang:element(
            3,
            R
        ) =< erlang:element(3, M@3)) ->
            [{s_range, erlang:element(2, R), erlang:element(2, M@3) - 1},
                transform_range(
                    {s_range, erlang:element(2, M@3), erlang:element(3, R)},
                    M@3
                ) |
                Acc];

        [M@4 | Ms@1] when (erlang:element(2, R) >= erlang:element(2, M@4)) andalso (erlang:element(
            3,
            R
        ) > erlang:element(3, M@4)) ->
            do_remap_range(
                {s_range, erlang:element(3, M@4) + 1, erlang:element(3, R)},
                Ms@1,
                [transform_range(
                        {s_range, erlang:element(2, R), erlang:element(3, M@4)},
                        M@4
                    ) |
                    Acc]
            );

        [M@5 | Ms@2] ->
            do_remap_range(
                {s_range, erlang:element(3, M@5) + 1, erlang:element(3, R)},
                Ms@2,
                [{s_range, erlang:element(2, R), erlang:element(2, M@5) - 1},
                    transform_range(
                        {s_range,
                            erlang:element(2, M@5),
                            erlang:element(3, M@5)},
                        M@5
                    ) |
                    Acc]
            )
    end.

-spec remap_range(seed_range(), list(mapping_range())) -> list(seed_range()).
remap_range(R, Mapper) ->
    do_remap_range(R, Mapper, []).

-spec remap_all_seed_ranges(list(seed_range()), list(list(mapping_range()))) -> list(seed_range()).
remap_all_seed_ranges(Srs, Mappers) ->
    case Mappers of
        [] ->
            Srs;

        [Mapper | Rest] ->
            _pipe = gleam@list:flat_map(
                Srs,
                fun(_capture) -> remap_range(_capture, Mapper) end
            ),
            remap_all_seed_ranges(_pipe, Rest)
    end.

-spec part2(binary()) -> binary().
part2(Input) ->
    {almanac, Seeds, Mappers} = parse_input(Input),
    _assert_subject = begin
        _pipe = Seeds,
        _pipe@1 = gleam@list:sized_chunk(_pipe, 2),
        _pipe@3 = gleam@list:map(
            _pipe@1,
            fun(Chunk) ->
                [Start, Length] = case Chunk of
                    [_, _] -> Chunk;
                    _assert_fail ->
                        erlang:error(#{gleam_error => let_assert,
                                    message => <<"Assertion pattern match failed"/utf8>>,
                                    value => _assert_fail,
                                    module => <<"day5/solve"/utf8>>,
                                    function => <<"part2"/utf8>>,
                                    line => 87})
                end,
                _pipe@2 = [{s_range, Start, (Start + Length) - 1}],
                remap_all_seed_ranges(_pipe@2, Mappers)
            end
        ),
        _pipe@4 = gleam@list:flatten(_pipe@3),
        gleam@list:sort(
            _pipe@4,
            fun(A, B) ->
                gleam@int:compare(erlang:element(2, A), erlang:element(2, B))
            end
        )
    end,
    [{s_range, Answer, _} | _] = case _assert_subject of
        [{s_range, _, _} | _] -> _assert_subject;
        _assert_fail@1 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail@1,
                        module => <<"day5/solve"/utf8>>,
                        function => <<"part2"/utf8>>,
                        line => 83})
    end,
    gleam@string:inspect(Answer).

-spec main() -> nil.
main() ->
    _assert_subject = adglent:get_part(),
    {ok, Part} = case _assert_subject of
        {ok, _} -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail,
                        module => <<"day5/solve"/utf8>>,
                        function => <<"main"/utf8>>,
                        line => 155})
    end,
    _assert_subject@1 = adglent:get_input(<<"5"/utf8>>),
    {ok, Input} = case _assert_subject@1 of
        {ok, _} -> _assert_subject@1;
        _assert_fail@1 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail@1,
                        module => <<"day5/solve"/utf8>>,
                        function => <<"main"/utf8>>,
                        line => 156})
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

-module(day22@solve).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch]).

-export([part1/1, part2/1, main/0]).
-export_type([point/0, block/0]).

-type point() :: {point, integer(), integer(), integer()}.

-type block() :: {block, integer(), point(), point()}.

-spec down_one(point()) -> point().
down_one(P) ->
    erlang:setelement(4, P, erlang:element(4, P) - 1).

-spec compare_blocks(block(), block()) -> gleam@order:order().
compare_blocks(B1, B2) ->
    gleam@int:compare(
        erlang:element(4, erlang:element(4, B1)),
        erlang:element(4, erlang:element(4, B2))
    ).

-spec parse_block(integer(), binary()) -> block().
parse_block(Index, Input) ->
    _assert_subject = gleam@regex:from_string(
        <<"(.*),(.*),(.*)~(.*),(.*),(.*)"/utf8>>
    ),
    {ok, Re} = case _assert_subject of
        {ok, _} -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail,
                        module => <<"day22/solve"/utf8>>,
                        function => <<"parse_block"/utf8>>,
                        line => 39})
    end,
    _assert_subject@1 = gleam@regex:scan(Re, Input),
    [Scan] = case _assert_subject@1 of
        [_] -> _assert_subject@1;
        _assert_fail@1 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail@1,
                        module => <<"day22/solve"/utf8>>,
                        function => <<"parse_block"/utf8>>,
                        line => 41})
    end,
    _assert_subject@2 = begin
        _pipe = erlang:element(3, Scan),
        _pipe@1 = gleam@option:all(_pipe),
        _pipe@2 = gleam@option:unwrap(_pipe@1, []),
        _pipe@3 = gleam@list:map(_pipe@2, fun gleam@int:parse/1),
        gleam@result:values(_pipe@3)
    end,
    [X1, Y1, Z1, X2, Y2, Z2] = case _assert_subject@2 of
        [_, _, _, _, _, _] -> _assert_subject@2;
        _assert_fail@2 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail@2,
                        module => <<"day22/solve"/utf8>>,
                        function => <<"parse_block"/utf8>>,
                        line => 43})
    end,
    {block, Index, {point, X1, Y1, Z1}, {point, X2, Y2, Z2}}.

-spec cross_section_at_level(block(), integer()) -> list(point()).
cross_section_at_level(B, Z) ->
    gleam@list:flat_map(
        gleam@list:range(
            erlang:element(2, erlang:element(3, B)),
            erlang:element(2, erlang:element(4, B))
        ),
        fun(X) ->
            gleam@list:map(
                gleam@list:range(
                    erlang:element(3, erlang:element(3, B)),
                    erlang:element(3, erlang:element(4, B))
                ),
                fun(Y) -> {point, X, Y, Z} end
            )
        end
    ).

-spec place_block(gleam@dict:dict(point(), block()), block(), integer()) -> gleam@dict:dict(point(), block()).
place_block(Space, B, Z) ->
    Now_occupied = (gleam@list:flat_map(
        gleam@list:range(
            erlang:element(2, erlang:element(3, B)),
            erlang:element(2, erlang:element(4, B))
        ),
        fun(X) ->
            gleam@list:flat_map(
                gleam@list:range(
                    erlang:element(3, erlang:element(3, B)),
                    erlang:element(3, erlang:element(4, B))
                ),
                fun(Y) ->
                    gleam@list:map(
                        gleam@list:range(
                            Z,
                            (Z + erlang:element(4, erlang:element(4, B))) - erlang:element(
                                4,
                                erlang:element(3, B)
                            )
                        ),
                        fun(Z@1) -> {{point, X, Y, Z@1}, B} end
                    )
                end
            )
        end
    )),
    gleam@dict:merge(Space, gleam@dict:from_list(Now_occupied)).

-spec do_find_lowest(gleam@dict:dict(point(), block()), block(), integer()) -> gleam@dict:dict(point(), block()).
do_find_lowest(Space, B, Z) ->
    Is_intersecting = gleam@list:any(
        cross_section_at_level(B, Z),
        fun(_capture) -> gleam@dict:has_key(Space, _capture) end
    ),
    case {Z, Is_intersecting} of
        {0, _} ->
            place_block(Space, B, 1);

        {_, true} ->
            place_block(Space, B, Z + 1);

        {_, false} ->
            do_find_lowest(Space, B, Z - 1)
    end.

-spec find_lowest_level(gleam@dict:dict(point(), block()), block()) -> gleam@dict:dict(point(), block()).
find_lowest_level(Space, B) ->
    do_find_lowest(Space, B, erlang:element(4, erlang:element(3, B))).

-spec to_block_positions(gleam@dict:dict(point(), block())) -> gleam@dict:dict(block(), list(point())).
to_block_positions(Space) ->
    gleam@dict:fold(
        Space,
        gleam@dict:new(),
        fun(Acc, Point, Index) ->
            gleam@dict:update(Acc, Index, fun(Points) -> case Points of
                        {some, Ps} ->
                            [Point | Ps];

                        none ->
                            [Point]
                    end end)
        end
    ).

-spec above_blocks(gleam@dict:dict(block(), list(point()))) -> gleam@dict:dict(integer(), gleam@set:set(integer())).
above_blocks(Blocks) ->
    gleam@dict:fold(
        Blocks,
        gleam@dict:new(),
        fun(Acc, Block, Points) ->
            gleam@dict:update(
                Acc,
                erlang:element(2, Block),
                fun(_) ->
                    _pipe = (gleam@dict:filter(
                        Blocks,
                        fun(Above_block, Above_points) ->
                            (erlang:element(2, Above_block) /= erlang:element(
                                2,
                                Block
                            ))
                            andalso gleam@list:any(
                                Above_points,
                                fun(P) ->
                                    gleam@list:contains(Points, down_one(P))
                                end
                            )
                        end
                    )),
                    _pipe@1 = gleam@dict:keys(_pipe),
                    _pipe@2 = gleam@list:map(
                        _pipe@1,
                        fun(B) -> erlang:element(2, B) end
                    ),
                    gleam@set:from_list(_pipe@2)
                end
            )
        end
    ).

-spec below_blocks(gleam@dict:dict(integer(), gleam@set:set(integer()))) -> gleam@dict:dict(integer(), gleam@set:set(integer())).
below_blocks(Blocktree) ->
    gleam@dict:fold(
        Blocktree,
        gleam@dict:new(),
        fun(Acc, Block, _) ->
            gleam@dict:update(
                Acc,
                Block,
                fun(_) ->
                    _pipe = (gleam@dict:filter(
                        Blocktree,
                        fun(_, Aboves) -> gleam@set:contains(Aboves, Block) end
                    )),
                    _pipe@1 = gleam@dict:keys(_pipe),
                    gleam@set:from_list(_pipe@1)
                end
            )
        end
    ).

-spec vulnerable_blocks(gleam@dict:dict(integer(), gleam@set:set(integer()))) -> list(integer()).
vulnerable_blocks(Below_tree) ->
    gleam@list:filter(
        gleam@dict:keys(Below_tree),
        fun(Block) ->
            gleam@list:any(
                gleam@dict:values(Below_tree),
                fun(Bs) ->
                    not (gleam@set:size(Bs) =:= 0) andalso (gleam@set:size(
                        gleam@set:delete(Bs, Block)
                    )
                    =:= 0)
                end
            )
        end
    ).

-spec part1(binary()) -> integer().
part1(Input) ->
    Settled_blocks = begin
        _pipe = Input,
        _pipe@1 = gleam@string:split(_pipe, <<"\n"/utf8>>),
        _pipe@2 = gleam@list:index_map(_pipe@1, fun parse_block/2),
        _pipe@3 = gleam@list:sort(_pipe@2, fun compare_blocks/2),
        gleam@list:fold(_pipe@3, gleam@dict:new(), fun find_lowest_level/2)
    end,
    Block_positions = to_block_positions(Settled_blocks),
    Above_blocks = above_blocks(Block_positions),
    Below_blocks = below_blocks(Above_blocks),
    Vulnerable_blocks = vulnerable_blocks(Below_blocks),
    gleam@list:length(gleam@dict:keys(Block_positions)) - gleam@list:length(
        Vulnerable_blocks
    ).

-spec do_falling_blocks(
    gleam@set:set(integer()),
    gleam@set:set(integer()),
    gleam@dict:dict(integer(), gleam@set:set(integer())),
    gleam@dict:dict(integer(), gleam@set:set(integer()))
) -> integer().
do_falling_blocks(Fallen, Blocks, Above, Below) ->
    gleam@bool:guard(
        gleam@set:size(Blocks) =:= 0,
        gleam@set:size(Fallen) - 1,
        fun() ->
            Blocks_above = begin
                _pipe = (gleam@list:flat_map(
                    gleam@set:to_list(Blocks),
                    fun(Block) ->
                        _assert_subject = gleam@dict:get(Above, Block),
                        {ok, Supports} = case _assert_subject of
                            {ok, _} -> _assert_subject;
                            _assert_fail ->
                                erlang:error(#{gleam_error => let_assert,
                                            message => <<"Assertion pattern match failed"/utf8>>,
                                            value => _assert_fail,
                                            module => <<"day22/solve"/utf8>>,
                                            function => <<"do_falling_blocks"/utf8>>,
                                            line => 156})
                        end,
                        gleam@list:filter(
                            gleam@set:to_list(Supports),
                            fun(Support) ->
                                _assert_subject@1 = gleam@dict:get(
                                    Below,
                                    Support
                                ),
                                {ok, Supportings} = case _assert_subject@1 of
                                    {ok, _} -> _assert_subject@1;
                                    _assert_fail@1 ->
                                        erlang:error(
                                                #{gleam_error => let_assert,
                                                    message => <<"Assertion pattern match failed"/utf8>>,
                                                    value => _assert_fail@1,
                                                    module => <<"day22/solve"/utf8>>,
                                                    function => <<"do_falling_blocks"/utf8>>,
                                                    line => 158}
                                            )
                                end,
                                gleam@list:all(
                                    gleam@set:to_list(Supportings),
                                    fun(Supporting) ->
                                        gleam@set:contains(Fallen, Supporting)
                                    end
                                )
                            end
                        )
                    end
                )),
                gleam@set:from_list(_pipe)
            end,
            _pipe@1 = gleam@set:union(Fallen, Blocks_above),
            do_falling_blocks(_pipe@1, Blocks_above, Above, Below)
        end
    ).

-spec all_falling_blocks(
    integer(),
    gleam@dict:dict(integer(), gleam@set:set(integer())),
    gleam@dict:dict(integer(), gleam@set:set(integer()))
) -> integer().
all_falling_blocks(N, Above, Below) ->
    Starting_set = gleam@set:insert(gleam@set:new(), N),
    do_falling_blocks(Starting_set, Starting_set, Above, Below).

-spec part2(binary()) -> integer().
part2(Input) ->
    Settled_blocks = begin
        _pipe = Input,
        _pipe@1 = gleam@string:split(_pipe, <<"\n"/utf8>>),
        _pipe@2 = gleam@list:index_map(_pipe@1, fun parse_block/2),
        _pipe@3 = gleam@list:sort(_pipe@2, fun compare_blocks/2),
        gleam@list:fold(_pipe@3, gleam@dict:new(), fun find_lowest_level/2)
    end,
    Block_positions = to_block_positions(Settled_blocks),
    Above_blocks = above_blocks(Block_positions),
    Below_blocks = below_blocks(Above_blocks),
    Vulnerable_blocks = vulnerable_blocks(Below_blocks),
    gleam@list:fold(
        Vulnerable_blocks,
        0,
        fun(Acc, B) ->
            Acc + all_falling_blocks(B, Above_blocks, Below_blocks)
        end
    ).

-spec main() -> nil.
main() ->
    _assert_subject = adglent:get_part(),
    {ok, Part} = case _assert_subject of
        {ok, _} -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail,
                        module => <<"day22/solve"/utf8>>,
                        function => <<"main"/utf8>>,
                        line => 187})
    end,
    _assert_subject@1 = adglent:get_input(<<"22"/utf8>>),
    {ok, Input} = case _assert_subject@1 of
        {ok, _} -> _assert_subject@1;
        _assert_fail@1 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail@1,
                        module => <<"day22/solve"/utf8>>,
                        function => <<"main"/utf8>>,
                        line => 188})
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

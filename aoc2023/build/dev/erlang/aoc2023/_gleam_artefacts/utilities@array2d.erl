-module(utilities@array2d).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function]).

-export([add_posns/2, to_2d_array/1, to_2d_intarray/1, to_list_of_lists/1, parse_grid/1]).
-export_type([posn/0]).

-type posn() :: {posn, integer(), integer()}.

-spec add_posns(posn(), posn()) -> posn().
add_posns(P1, P2) ->
    case {P1, P2} of
        {{posn, R1, C1}, {posn, R2, C2}} ->
            {posn, R1 + R2, C1 + C2}
    end.

-spec to_2d_array(list(list(BDY))) -> gleam@dict:dict(posn(), BDY).
to_2d_array(Xss) ->
    _pipe = (gleam@list:index_map(
        Xss,
        fun(R, Row) ->
            gleam@list:index_map(Row, fun(C, Cell) -> {{posn, R, C}, Cell} end)
        end
    )),
    _pipe@1 = gleam@list:flatten(_pipe),
    gleam@dict:from_list(_pipe@1).

-spec to_2d_intarray(list(list(binary()))) -> gleam@dict:dict(posn(), integer()).
to_2d_intarray(Xss) ->
    _pipe = (gleam@list:index_map(
        Xss,
        fun(R, Row) ->
            gleam@list:index_map(
                Row,
                fun(C, Cell) ->
                    _assert_subject = gleam@int:parse(Cell),
                    {ok, N} = case _assert_subject of
                        {ok, _} -> _assert_subject;
                        _assert_fail ->
                            erlang:error(#{gleam_error => let_assert,
                                        message => <<"Assertion pattern match failed"/utf8>>,
                                        value => _assert_fail,
                                        module => <<"utilities/array2d"/utf8>>,
                                        function => <<"to_2d_intarray"/utf8>>,
                                        line => 33})
                    end,
                    {{posn, R, C}, N}
                end
            )
        end
    )),
    _pipe@1 = gleam@list:flatten(_pipe),
    gleam@dict:from_list(_pipe@1).

-spec to_list_of_lists(binary()) -> list(list(binary())).
to_list_of_lists(Str) ->
    _pipe = Str,
    _pipe@1 = gleam@string:split(_pipe, <<"\n"/utf8>>),
    gleam@list:map(_pipe@1, fun gleam@string:to_graphemes/1).

-spec parse_grid(binary()) -> gleam@dict:dict(posn(), binary()).
parse_grid(Str) ->
    _pipe = Str,
    _pipe@1 = to_list_of_lists(_pipe),
    to_2d_array(_pipe@1).

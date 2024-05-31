-module(utilities@array2d).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch]).

-export([add_posns/2, ortho_neighbors/1, to_2d_array_using/2, to_2d_array/1, to_2d_intarray/1, to_list_of_lists/1, parse_grid_using/2, parse_grid/1]).
-export_type([posn/0]).

-type posn() :: {posn, integer(), integer()}.

-spec add_posns(posn(), posn()) -> posn().
add_posns(P1, P2) ->
    case {P1, P2} of
        {{posn, R1, C1}, {posn, R2, C2}} ->
            {posn, R1 + R2, C1 + C2}
    end.

-spec ortho_neighbors(posn()) -> list(posn()).
ortho_neighbors(P) ->
    {posn, R, C} = P,
    [{posn, R + 1, C}, {posn, R - 1, C}, {posn, R, C + 1}, {posn, R, C - 1}].

-spec to_2d_array_using(list(list(PSV)), fun((PSV) -> {ok, PSY} | {error, nil})) -> gleam@dict:dict(posn(), PSY).
to_2d_array_using(Xss, F) ->
    _pipe = (gleam@list:index_map(
        Xss,
        fun(R, Row) -> gleam@list:index_map(Row, fun(C, Cell) -> case F(Cell) of
                        {ok, Contents} ->
                            {ok, {{posn, R, C}, Contents}};

                        {error, nil} ->
                            {error, nil}
                    end end) end
    )),
    _pipe@1 = gleam@list:flatten(_pipe),
    _pipe@2 = gleam@result:values(_pipe@1),
    gleam@dict:from_list(_pipe@2).

-spec to_2d_array(list(list(PSR))) -> gleam@dict:dict(posn(), PSR).
to_2d_array(Xss) ->
    to_2d_array_using(Xss, fun(X) -> {ok, X} end).

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
                                        line => 50})
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

-spec parse_grid_using(binary(), fun((binary()) -> {ok, PTI} | {error, nil})) -> gleam@dict:dict(posn(), PTI).
parse_grid_using(Str, F) ->
    _pipe = Str,
    _pipe@1 = to_list_of_lists(_pipe),
    to_2d_array_using(_pipe@1, F).

-spec parse_grid(binary()) -> gleam@dict:dict(posn(), binary()).
parse_grid(Str) ->
    parse_grid_using(Str, fun(X) -> {ok, X} end).

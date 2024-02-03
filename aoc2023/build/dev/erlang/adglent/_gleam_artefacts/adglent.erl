-module(adglent).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function]).

-export([inspect/1, get_input/1, get_test_folder/1, start_arguments/0, get_part/0]).
-export_type([example/1, problem/0, charlist/0]).

-type example(ODD) :: {example, binary(), ODD}.

-type problem() :: first | second.

-type charlist() :: any().

-spec inspect(any()) -> binary().
inspect(Value) ->
    Inspected_value = gleam@string:inspect(Value),
    case begin
        _pipe = Inspected_value,
        gleam@string:starts_with(_pipe, <<"\""/utf8>>)
    end of
        true ->
            _pipe@1 = Inspected_value,
            _pipe@2 = gleam@string:drop_left(_pipe@1, 1),
            gleam@string:drop_right(_pipe@2, 1);

        false ->
            Inspected_value
    end.

-spec get_input(binary()) -> {ok, binary()} | {error, simplifile:file_error()}.
get_input(Day) ->
    simplifile:read(
        <<<<"src/day"/utf8, Day/binary>>/binary, "/input.txt"/utf8>>
    ).

-spec get_test_folder(binary()) -> binary().
get_test_folder(Day) ->
    <<"test/day"/utf8, Day/binary>>.

-spec start_arguments() -> list(binary()).
start_arguments() ->
    _pipe = init:get_plain_arguments(),
    gleam@list:map(_pipe, fun unicode:characters_to_binary/1).

-spec get_part() -> {ok, problem()} | {error, nil}.
get_part() ->
    case start_arguments() of
        [<<"1"/utf8>>] ->
            {ok, first};

        [<<"2"/utf8>>] ->
            {ok, second};

        _ ->
            {error, nil}
    end.

-module(priv@errors).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function]).

-export([map_messages/3, map_error/2, print_result/1, print_error/1, assert_ok/1]).

-spec map_messages({ok, any()} | {error, any()}, binary(), binary()) -> {ok,
        binary()} |
    {error, binary()}.
map_messages(Result, Success_message, Error_message) ->
    _pipe = Result,
    _pipe@1 = gleam@result:map_error(
        _pipe,
        fun(Error) ->
            <<<<<<"Error - "/utf8, Error_message/binary>>/binary, ": "/utf8>>/binary,
                (gleam@string:inspect(Error))/binary>>
        end
    ),
    gleam@result:replace(_pipe@1, Success_message).

-spec map_error({ok, NIB} | {error, any()}, binary()) -> {ok, NIB} |
    {error, binary()}.
map_error(Result, Error_message) ->
    _pipe = Result,
    gleam@result:map_error(
        _pipe,
        fun(Error) ->
            <<<<Error_message/binary, ": "/utf8>>/binary,
                (gleam@string:inspect(Error))/binary>>
        end
    ).

-spec print_result({ok, binary()} | {error, binary()}) -> {ok, binary()} |
    {error, binary()}.
print_result(Result) ->
    _pipe = Result,
    _pipe@1 = gleam@result:unwrap_both(_pipe),
    gleam@io:println(_pipe@1),
    Result.

-spec print_error({ok, NIK} | {error, binary()}) -> {ok, NIK} |
    {error, binary()}.
print_error(Result) ->
    _pipe = Result,
    gleam@result:map_error(
        _pipe,
        fun(Err) ->
            gleam@io:println(Err),
            Err
        end
    ).

-spec assert_ok({ok, NIO} | {error, binary()}) -> NIO.
assert_ok(Result) ->
    _assert_subject = begin
        _pipe = Result,
        gleam@result:map_error(
            _pipe,
            fun(Err) ->
                erlang:halt(1),
                Err
            end
        )
    end,
    {ok, Value} = case _assert_subject of
        {ok, _} -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail,
                        module => <<"priv/errors"/utf8>>,
                        function => <<"assert_ok"/utf8>>,
                        line => 43})
    end,
    Value.

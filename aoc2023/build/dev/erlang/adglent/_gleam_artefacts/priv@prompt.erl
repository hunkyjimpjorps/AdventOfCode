-module(priv@prompt).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch]).

-export([get_line/1, confirm/2, value/3]).
-export_type([get_line_error/0]).

-type get_line_error() :: eof | no_data.

-spec get_line(binary()) -> {ok, binary()} | {error, get_line_error()}.
get_line(Prompt) ->
    adglent_ffi:get_line(Prompt).

-spec confirm(binary(), boolean()) -> boolean().
confirm(Message, Auto_accept) ->
    Auto_accept orelse case begin
        _pipe = adglent_ffi:get_line(<<Message/binary, "? (Y/N): "/utf8>>),
        _pipe@1 = gleam@result:unwrap(_pipe, <<"n"/utf8>>),
        gleam@string:trim(_pipe@1)
    end of
        <<"Y"/utf8>> ->
            true;

        <<"y"/utf8>> ->
            true;

        _ ->
            false
    end.

-spec get_value_of_default(binary(), binary(), boolean()) -> binary().
get_value_of_default(Message, Default, Auto_accept) ->
    case Auto_accept of
        true ->
            Default;

        false ->
            _pipe = adglent_ffi:get_line(
                <<<<<<Message/binary, "? ("/utf8>>/binary, Default/binary>>/binary,
                    "): "/utf8>>
            ),
            _pipe@1 = gleam@result:unwrap(_pipe, <<""/utf8>>),
            gleam@string:trim(_pipe@1)
    end.

-spec value(binary(), binary(), boolean()) -> binary().
value(Message, Default, Auto_accept) ->
    case get_value_of_default(Message, Default, Auto_accept) of
        <<""/utf8>> ->
            Default;

        Value ->
            Value
    end.

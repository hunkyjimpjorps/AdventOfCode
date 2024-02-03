-module(priv@toml).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function]).

-export([get_string/2, get_bool/2, get_int/2]).
-export_type([tom_error/0]).

-type tom_error() :: {tom_parse_error, tom:parse_error()} |
    {tom_get_error, tom:get_error()}.

-spec get_string(binary(), list(binary())) -> {ok, binary()} |
    {error, tom_error()}.
get_string(Toml_content, Key_path) ->
    gleam@result:'try'(
        begin
            _pipe = tom:parse(<<Toml_content/binary, "\n"/utf8>>),
            gleam@result:map_error(
                _pipe,
                fun(Field@0) -> {tom_parse_error, Field@0} end
            )
        end,
        fun(Toml) ->
            gleam@result:'try'(
                begin
                    _pipe@1 = tom:get_string(Toml, Key_path),
                    gleam@result:map_error(
                        _pipe@1,
                        fun(Field@0) -> {tom_get_error, Field@0} end
                    )
                end,
                fun(Value) -> {ok, Value} end
            )
        end
    ).

-spec get_bool(binary(), list(binary())) -> {ok, boolean()} |
    {error, tom_error()}.
get_bool(Toml_content, Key_path) ->
    gleam@result:'try'(
        begin
            _pipe = tom:parse(<<Toml_content/binary, "\n"/utf8>>),
            gleam@result:map_error(
                _pipe,
                fun(Field@0) -> {tom_parse_error, Field@0} end
            )
        end,
        fun(Toml) ->
            gleam@result:'try'(
                begin
                    _pipe@1 = tom:get_bool(Toml, Key_path),
                    gleam@result:map_error(
                        _pipe@1,
                        fun(Field@0) -> {tom_get_error, Field@0} end
                    )
                end,
                fun(Value) -> {ok, Value} end
            )
        end
    ).

-spec get_int(binary(), list(binary())) -> {ok, integer()} |
    {error, tom_error()}.
get_int(Toml_content, Key_path) ->
    gleam@result:'try'(
        begin
            _pipe = tom:parse(<<Toml_content/binary, "\n"/utf8>>),
            gleam@result:map_error(
                _pipe,
                fun(Field@0) -> {tom_parse_error, Field@0} end
            )
        end,
        fun(Toml) ->
            gleam@result:'try'(
                begin
                    _pipe@1 = tom:get_int(Toml, Key_path),
                    gleam@result:map_error(
                        _pipe@1,
                        fun(Field@0) -> {tom_get_error, Field@0} end
                    )
                end,
                fun(Value) -> {ok, Value} end
            )
        end
    ).

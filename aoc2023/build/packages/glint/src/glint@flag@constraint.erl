-module(glint@flag@constraint).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function]).

-export([one_of/1, none_of/1, each/1]).

-spec one_of(list(FSI)) -> fun((FSI) -> {ok, nil} | {error, snag:snag()}).
one_of(Allowed) ->
    Allowed_set = gleam@set:from_list(Allowed),
    fun(Val) -> case gleam@set:contains(Allowed_set, Val) of
            true ->
                {ok, nil};

            false ->
                snag:error(
                    <<<<<<"invalid value '"/utf8,
                                (gleam@string:inspect(Val))/binary>>/binary,
                            "', must be one of: ["/utf8>>/binary,
                        ((<<(begin
                                _pipe = Allowed,
                                _pipe@1 = gleam@list:map(
                                    _pipe,
                                    fun(A) ->
                                        <<<<"'"/utf8,
                                                (gleam@string:inspect(A))/binary>>/binary,
                                            "'"/utf8>>
                                    end
                                ),
                                gleam@string:join(_pipe@1, <<", "/utf8>>)
                            end)/binary,
                            "]"/utf8>>))/binary>>
                )
        end end.

-spec none_of(list(FSL)) -> fun((FSL) -> {ok, nil} | {error, snag:snag()}).
none_of(Disallowed) ->
    Disallowed_set = gleam@set:from_list(Disallowed),
    fun(Val) -> case gleam@set:contains(Disallowed_set, Val) of
            false ->
                {ok, nil};

            true ->
                snag:error(
                    <<<<<<"invalid value '"/utf8,
                                (gleam@string:inspect(Val))/binary>>/binary,
                            "', must not be one of: ["/utf8>>/binary,
                        (((<<(begin
                                _pipe = Disallowed,
                                _pipe@1 = gleam@list:map(
                                    _pipe,
                                    fun(A) ->
                                        <<<<"'"/utf8,
                                                (gleam@string:inspect(A))/binary>>/binary,
                                            "'"/utf8>>
                                    end
                                ),
                                gleam@string:join(_pipe@1, <<", "/utf8>>)
                            end)/binary,
                            "]"/utf8>>)))/binary>>
                )
        end end.

-spec each(fun((FSO) -> {ok, nil} | {error, snag:snag()})) -> fun((list(FSO)) -> {ok,
        nil} |
    {error, snag:snag()}).
each(Constraint) ->
    fun(L) -> _pipe = L,
        _pipe@1 = gleam@list:try_map(_pipe, Constraint),
        gleam@result:replace(_pipe@1, nil) end.

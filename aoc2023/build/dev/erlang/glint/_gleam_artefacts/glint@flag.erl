-module(glint@flag).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function]).

-export([string/0, string_list/0, build/1, constraint/2, description/2, default/2, build_map/1, int/0, int_list/0, float/0, float_list/0, bool/0, flag_type_help/1, flags_help/1, update_flags/2, get_int_value/1, get_int/2, get_ints_value/1, get_ints/2, get_bool_value/1, get_bool/2, get_string_value/1, get_string/2, get_strings_value/1, get_strings/2, get_float_value/1, get_float/2, get_floats_value/1, get_floats/2]).
-export_type([value/0, flag_builder/1, internal/1, flag/0]).

-type value() :: {b, internal(boolean())} |
    {i, internal(integer())} |
    {li, internal(list(integer()))} |
    {f, internal(float())} |
    {lf, internal(list(float()))} |
    {s, internal(binary())} |
    {ls, internal(list(binary()))}.

-opaque flag_builder(IRX) :: {flag_builder,
        binary(),
        fun((binary()) -> {ok, IRX} | {error, snag:snag()}),
        fun((internal(IRX)) -> value()),
        gleam@option:option(IRX)}.

-opaque internal(IRY) :: {internal,
        gleam@option:option(IRY),
        fun((binary()) -> {ok, IRY} | {error, snag:snag()})}.

-type flag() :: {flag, value(), binary()}.

-spec new(
    fun((internal(ISP)) -> value()),
    fun((binary()) -> {ok, ISP} | {error, snag:snag()})
) -> flag_builder(ISP).
new(Valuer, P) ->
    {flag_builder, <<""/utf8>>, P, Valuer, none}.

-spec string() -> flag_builder(binary()).
string() ->
    new(fun(Field@0) -> {s, Field@0} end, fun(S) -> {ok, S} end).

-spec string_list() -> flag_builder(list(binary())).
string_list() ->
    new(fun(Field@0) -> {ls, Field@0} end, fun(Input) -> _pipe = Input,
            _pipe@1 = gleam@string:split(_pipe, <<","/utf8>>),
            {ok, _pipe@1} end).

-spec build(flag_builder(any())) -> flag().
build(Fb) ->
    {flag,
        (erlang:element(4, Fb))(
            {internal, erlang:element(5, Fb), erlang:element(3, Fb)}
        ),
        erlang:element(2, Fb)}.

-spec attempt(
    {ok, ITG} | {error, ITH},
    fun((ITG) -> {ok, any()} | {error, ITH})
) -> {ok, ITG} | {error, ITH}.
attempt(Val, F) ->
    gleam@result:'try'(Val, fun(A) -> gleam@result:replace(F(A), A) end).

-spec wrap_with_constraint(
    fun((binary()) -> {ok, ITA} | {error, snag:snag()}),
    fun((ITA) -> {ok, nil} | {error, snag:snag()})
) -> fun((binary()) -> {ok, ITA} | {error, snag:snag()}).
wrap_with_constraint(P, Constraint) ->
    fun(Input) -> attempt(P(Input), Constraint) end.

-spec constraint(
    flag_builder(ISW),
    fun((ISW) -> {ok, nil} | {error, snag:snag()})
) -> flag_builder(ISW).
constraint(Builder, Constraint) ->
    erlang:setelement(
        3,
        Builder,
        wrap_with_constraint(erlang:element(3, Builder), Constraint)
    ).

-spec description(flag_builder(ITP), binary()) -> flag_builder(ITP).
description(Builder, Description) ->
    erlang:setelement(2, Builder, Description).

-spec default(flag_builder(ITS), ITS) -> flag_builder(ITS).
default(Builder, Default) ->
    erlang:setelement(5, Builder, {some, Default}).

-spec build_map(list({binary(), flag()})) -> gleam@dict:dict(binary(), flag()).
build_map(Flags) ->
    gleam@map:from_list(Flags).

-spec access_type_error(binary()) -> {ok, any()} | {error, snag:snag()}.
access_type_error(Flag_type) ->
    snag:error(<<"cannot access flag as "/utf8, Flag_type/binary>>).

-spec flag_not_provided_error() -> {ok, any()} | {error, snag:snag()}.
flag_not_provided_error() ->
    snag:error(<<"no value provided"/utf8>>).

-spec construct_value(binary(), internal(IUC), fun((internal(IUC)) -> value())) -> {ok,
        value()} |
    {error, snag:snag()}.
construct_value(Input, Internal, Constructor) ->
    gleam@result:map(
        (erlang:element(3, Internal))(Input),
        fun(Val) -> Constructor(erlang:setelement(2, Internal, {some, Val})) end
    ).

-spec compute_flag(binary(), value()) -> {ok, value()} | {error, snag:snag()}.
compute_flag(Input, Current) ->
    _pipe = Input,
    _pipe@1 = case Current of
        {i, Internal} ->
            fun(_capture) ->
                construct_value(
                    _capture,
                    Internal,
                    fun(Field@0) -> {i, Field@0} end
                )
            end;

        {li, Internal@1} ->
            fun(_capture@1) ->
                construct_value(
                    _capture@1,
                    Internal@1,
                    fun(Field@0) -> {li, Field@0} end
                )
            end;

        {f, Internal@2} ->
            fun(_capture@2) ->
                construct_value(
                    _capture@2,
                    Internal@2,
                    fun(Field@0) -> {f, Field@0} end
                )
            end;

        {lf, Internal@3} ->
            fun(_capture@3) ->
                construct_value(
                    _capture@3,
                    Internal@3,
                    fun(Field@0) -> {lf, Field@0} end
                )
            end;

        {s, Internal@4} ->
            fun(_capture@4) ->
                construct_value(
                    _capture@4,
                    Internal@4,
                    fun(Field@0) -> {s, Field@0} end
                )
            end;

        {ls, Internal@5} ->
            fun(_capture@5) ->
                construct_value(
                    _capture@5,
                    Internal@5,
                    fun(Field@0) -> {ls, Field@0} end
                )
            end;

        {b, Internal@6} ->
            fun(_capture@6) ->
                construct_value(
                    _capture@6,
                    Internal@6,
                    fun(Field@0) -> {b, Field@0} end
                )
            end
    end(_pipe),
    snag:context(_pipe@1, <<"failed to compute value for flag"/utf8>>).

-spec layer_invalid_flag(snag:snag(), binary()) -> snag:snag().
layer_invalid_flag(Err, Flag) ->
    snag:layer(Err, <<<<"invalid flag '"/utf8, Flag/binary>>/binary, "'"/utf8>>).

-spec no_value_flag_err(binary()) -> snag:snag().
no_value_flag_err(Flag_input) ->
    _pipe = (<<<<"flag '"/utf8, Flag_input/binary>>/binary,
        "' has no assigned value"/utf8>>),
    _pipe@1 = snag:new(_pipe),
    layer_invalid_flag(_pipe@1, Flag_input).

-spec undefined_flag_err(binary()) -> snag:snag().
undefined_flag_err(Key) ->
    _pipe = <<"flag provided but not defined"/utf8>>,
    _pipe@1 = snag:new(_pipe),
    layer_invalid_flag(_pipe@1, Key).

-spec cannot_parse(binary(), binary()) -> snag:snag().
cannot_parse(Value, Kind) ->
    _pipe = (<<<<<<"cannot parse value '"/utf8, Value/binary>>/binary,
            "' as "/utf8>>/binary,
        Kind/binary>>),
    snag:new(_pipe).

-spec int() -> flag_builder(integer()).
int() ->
    new(fun(Field@0) -> {i, Field@0} end, fun(Input) -> _pipe = Input,
            _pipe@1 = gleam@int:parse(_pipe),
            gleam@result:replace_error(
                _pipe@1,
                cannot_parse(Input, <<"int"/utf8>>)
            ) end).

-spec int_list() -> flag_builder(list(integer())).
int_list() ->
    new(fun(Field@0) -> {li, Field@0} end, fun(Input) -> _pipe = Input,
            _pipe@1 = gleam@string:split(_pipe, <<","/utf8>>),
            _pipe@2 = gleam@list:try_map(_pipe@1, fun gleam@int:parse/1),
            gleam@result:replace_error(
                _pipe@2,
                cannot_parse(Input, <<"int list"/utf8>>)
            ) end).

-spec float() -> flag_builder(float()).
float() ->
    new(fun(Field@0) -> {f, Field@0} end, fun(Input) -> _pipe = Input,
            _pipe@1 = gleam@float:parse(_pipe),
            gleam@result:replace_error(
                _pipe@1,
                cannot_parse(Input, <<"float"/utf8>>)
            ) end).

-spec float_list() -> flag_builder(list(float())).
float_list() ->
    new(fun(Field@0) -> {lf, Field@0} end, fun(Input) -> _pipe = Input,
            _pipe@1 = gleam@string:split(_pipe, <<","/utf8>>),
            _pipe@2 = gleam@list:try_map(_pipe@1, fun gleam@float:parse/1),
            gleam@result:replace_error(
                _pipe@2,
                cannot_parse(Input, <<"float list"/utf8>>)
            ) end).

-spec bool() -> flag_builder(boolean()).
bool() ->
    new(
        fun(Field@0) -> {b, Field@0} end,
        fun(Input) -> case gleam@string:lowercase(Input) of
                <<"true"/utf8>> ->
                    {ok, true};

                <<"t"/utf8>> ->
                    {ok, true};

                <<"false"/utf8>> ->
                    {ok, false};

                <<"f"/utf8>> ->
                    {ok, false};

                _ ->
                    {error, cannot_parse(Input, <<"bool"/utf8>>)}
            end end
    ).

-spec flag_type_help({binary(), flag()}) -> binary().
flag_type_help(Flag) ->
    {Name, Contents} = Flag,
    Kind = case erlang:element(2, Contents) of
        {i, _} ->
            <<"INT"/utf8>>;

        {b, _} ->
            <<"BOOL"/utf8>>;

        {f, _} ->
            <<"FLOAT"/utf8>>;

        {lf, _} ->
            <<"FLOAT_LIST"/utf8>>;

        {li, _} ->
            <<"INT_LIST"/utf8>>;

        {ls, _} ->
            <<"STRING_LIST"/utf8>>;

        {s, _} ->
            <<"STRING"/utf8>>
    end,
    <<<<<<<<<<"--"/utf8, Name/binary>>/binary, "="/utf8>>/binary, "<"/utf8>>/binary,
            Kind/binary>>/binary,
        ">"/utf8>>.

-spec flag_help({binary(), flag()}) -> binary().
flag_help(Flag) ->
    <<<<(flag_type_help(Flag))/binary, "\t\t"/utf8>>/binary,
        (erlang:element(3, (erlang:element(2, Flag))))/binary>>.

-spec flags_help(gleam@dict:dict(binary(), flag())) -> list(binary()).
flags_help(Flags) ->
    _pipe = Flags,
    _pipe@1 = gleam@map:to_list(_pipe),
    gleam@list:map(_pipe@1, fun flag_help/1).

-spec access(gleam@dict:dict(binary(), flag()), binary()) -> {ok, flag()} |
    {error, snag:snag()}.
access(Flags, Name) ->
    _pipe = gleam@map:get(Flags, Name),
    gleam@result:replace_error(_pipe, undefined_flag_err(Name)).

-spec update_flag_value(gleam@dict:dict(binary(), flag()), {binary(), binary()}) -> {ok,
        gleam@dict:dict(binary(), flag())} |
    {error, snag:snag()}.
update_flag_value(Flags, Data) ->
    {Key, Input} = Data,
    gleam@result:'try'(
        access(Flags, Key),
        fun(Contents) ->
            gleam@result:map(
                begin
                    _pipe = compute_flag(Input, erlang:element(2, Contents)),
                    gleam@result:map_error(
                        _pipe,
                        fun(_capture) -> layer_invalid_flag(_capture, Key) end
                    )
                end,
                fun(Value) ->
                    gleam@map:insert(
                        Flags,
                        Key,
                        erlang:setelement(2, Contents, Value)
                    )
                end
            )
        end
    ).

-spec attempt_toggle_flag(gleam@dict:dict(binary(), flag()), binary()) -> {ok,
        gleam@dict:dict(binary(), flag())} |
    {error, snag:snag()}.
attempt_toggle_flag(Flags, Key) ->
    gleam@result:'try'(
        access(Flags, Key),
        fun(Contents) -> case erlang:element(2, Contents) of
                {b, {internal, none, _} = Internal} ->
                    _pipe = erlang:setelement(2, Internal, {some, true}),
                    _pipe@1 = {b, _pipe},
                    _pipe@2 = (fun(Val) ->
                        erlang:setelement(2, Contents, Val)
                    end)(_pipe@1),
                    _pipe@3 = gleam@map:insert(Flags, Key, _pipe@2),
                    {ok, _pipe@3};

                {b, {internal, {some, Val@1}, _} = Internal@1} ->
                    _pipe@4 = erlang:setelement(
                        2,
                        Internal@1,
                        {some, not Val@1}
                    ),
                    _pipe@5 = {b, _pipe@4},
                    _pipe@6 = (fun(Val@2) ->
                        erlang:setelement(2, Contents, Val@2)
                    end)(_pipe@5),
                    _pipe@7 = gleam@map:insert(Flags, Key, _pipe@6),
                    {ok, _pipe@7};

                _ ->
                    {error, no_value_flag_err(Key)}
            end end
    ).

-spec update_flags(gleam@dict:dict(binary(), flag()), binary()) -> {ok,
        gleam@dict:dict(binary(), flag())} |
    {error, snag:snag()}.
update_flags(Flags, Flag_input) ->
    Flag_input@1 = gleam@string:drop_left(
        Flag_input,
        gleam@string:length(<<"--"/utf8>>)
    ),
    case gleam@string:split_once(Flag_input@1, <<"="/utf8>>) of
        {ok, Data} ->
            update_flag_value(Flags, Data);

        {error, _} ->
            attempt_toggle_flag(Flags, Flag_input@1)
    end.

-spec get_value(
    gleam@dict:dict(binary(), flag()),
    binary(),
    fun((flag()) -> {ok, IUK} | {error, snag:snag()})
) -> {ok, IUK} | {error, snag:snag()}.
get_value(Flags, Key, Kind) ->
    _pipe = access(Flags, Key),
    _pipe@1 = gleam@result:'try'(_pipe, Kind),
    snag:context(
        _pipe@1,
        <<<<"failed to retrieve value for flag '"/utf8, Key/binary>>/binary,
            "'"/utf8>>
    ).

-spec get_int_value(flag()) -> {ok, integer()} | {error, snag:snag()}.
get_int_value(Flag) ->
    case erlang:element(2, Flag) of
        {i, {internal, {some, Val}, _}} ->
            {ok, Val};

        {i, {internal, none, _}} ->
            flag_not_provided_error();

        _ ->
            access_type_error(<<"int"/utf8>>)
    end.

-spec get_int(gleam@dict:dict(binary(), flag()), binary()) -> {ok, integer()} |
    {error, snag:snag()}.
get_int(Flags, Name) ->
    get_value(Flags, Name, fun get_int_value/1).

-spec get_ints_value(flag()) -> {ok, list(integer())} | {error, snag:snag()}.
get_ints_value(Flag) ->
    case erlang:element(2, Flag) of
        {li, {internal, {some, Val}, _}} ->
            {ok, Val};

        {li, {internal, none, _}} ->
            flag_not_provided_error();

        _ ->
            access_type_error(<<"int list"/utf8>>)
    end.

-spec get_ints(gleam@dict:dict(binary(), flag()), binary()) -> {ok,
        list(integer())} |
    {error, snag:snag()}.
get_ints(Flags, Name) ->
    get_value(Flags, Name, fun get_ints_value/1).

-spec get_bool_value(flag()) -> {ok, boolean()} | {error, snag:snag()}.
get_bool_value(Flag) ->
    case erlang:element(2, Flag) of
        {b, {internal, {some, Val}, _}} ->
            {ok, Val};

        {b, {internal, none, _}} ->
            flag_not_provided_error();

        _ ->
            access_type_error(<<"bool"/utf8>>)
    end.

-spec get_bool(gleam@dict:dict(binary(), flag()), binary()) -> {ok, boolean()} |
    {error, snag:snag()}.
get_bool(Flags, Name) ->
    get_value(Flags, Name, fun get_bool_value/1).

-spec get_string_value(flag()) -> {ok, binary()} | {error, snag:snag()}.
get_string_value(Flag) ->
    case erlang:element(2, Flag) of
        {s, {internal, {some, Val}, _}} ->
            {ok, Val};

        {s, {internal, none, _}} ->
            flag_not_provided_error();

        _ ->
            access_type_error(<<"string"/utf8>>)
    end.

-spec get_string(gleam@dict:dict(binary(), flag()), binary()) -> {ok, binary()} |
    {error, snag:snag()}.
get_string(Flags, Name) ->
    get_value(Flags, Name, fun get_string_value/1).

-spec get_strings_value(flag()) -> {ok, list(binary())} | {error, snag:snag()}.
get_strings_value(Flag) ->
    case erlang:element(2, Flag) of
        {ls, {internal, {some, Val}, _}} ->
            {ok, Val};

        {ls, {internal, none, _}} ->
            flag_not_provided_error();

        _ ->
            access_type_error(<<"string list"/utf8>>)
    end.

-spec get_strings(gleam@dict:dict(binary(), flag()), binary()) -> {ok,
        list(binary())} |
    {error, snag:snag()}.
get_strings(Flags, Name) ->
    get_value(Flags, Name, fun get_strings_value/1).

-spec get_float_value(flag()) -> {ok, float()} | {error, snag:snag()}.
get_float_value(Flag) ->
    case erlang:element(2, Flag) of
        {f, {internal, {some, Val}, _}} ->
            {ok, Val};

        {f, {internal, none, _}} ->
            flag_not_provided_error();

        _ ->
            access_type_error(<<"float"/utf8>>)
    end.

-spec get_float(gleam@dict:dict(binary(), flag()), binary()) -> {ok, float()} |
    {error, snag:snag()}.
get_float(Flags, Name) ->
    get_value(Flags, Name, fun get_float_value/1).

-spec get_floats_value(flag()) -> {ok, list(float())} | {error, snag:snag()}.
get_floats_value(Flag) ->
    case erlang:element(2, Flag) of
        {lf, {internal, {some, Val}, _}} ->
            {ok, Val};

        {lf, {internal, none, _}} ->
            flag_not_provided_error();

        _ ->
            access_type_error(<<"float list"/utf8>>)
    end.

-spec get_floats(gleam@dict:dict(binary(), flag()), binary()) -> {ok,
        list(float())} |
    {error, snag:snag()}.
get_floats(Flags, Name) ->
    get_value(Flags, Name, fun get_floats_value/1).

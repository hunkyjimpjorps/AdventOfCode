-module(gleam@dynamic).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch]).

-export([from/1, unsafe_coerce/1, dynamic/1, bit_array/1, bit_string/1, classify/1, int/1, float/1, bool/1, shallow_list/1, optional/1, any/1, decode1/2, result/2, list/1, string/1, field/2, optional_field/2, element/2, tuple2/2, tuple3/3, tuple4/4, tuple5/5, tuple6/6, dict/2, map/2, decode2/3, decode3/4, decode4/5, decode5/6, decode6/7, decode7/8, decode8/9, decode9/10]).
-export_type([dynamic_/0, decode_error/0, unknown_tuple/0]).

-type dynamic_() :: any().

-type decode_error() :: {decode_error, binary(), binary(), list(binary())}.

-type unknown_tuple() :: any().

-spec from(any()) -> dynamic_().
from(A) ->
    gleam_stdlib:identity(A).

-spec unsafe_coerce(dynamic_()) -> any().
unsafe_coerce(A) ->
    gleam_stdlib:identity(A).

-spec dynamic(dynamic_()) -> {ok, dynamic_()} | {error, list(decode_error())}.
dynamic(Value) ->
    {ok, Value}.

-spec bit_array(dynamic_()) -> {ok, bitstring()} | {error, list(decode_error())}.
bit_array(Data) ->
    gleam_stdlib:decode_bit_array(Data).

-spec bit_string(dynamic_()) -> {ok, bitstring()} |
    {error, list(decode_error())}.
bit_string(Data) ->
    bit_array(Data).

-spec put_expected(decode_error(), binary()) -> decode_error().
put_expected(Error, Expected) ->
    erlang:setelement(2, Error, Expected).

-spec classify(dynamic_()) -> binary().
classify(Data) ->
    gleam_stdlib:classify_dynamic(Data).

-spec int(dynamic_()) -> {ok, integer()} | {error, list(decode_error())}.
int(Data) ->
    gleam_stdlib:decode_int(Data).

-spec float(dynamic_()) -> {ok, float()} | {error, list(decode_error())}.
float(Data) ->
    gleam_stdlib:decode_float(Data).

-spec bool(dynamic_()) -> {ok, boolean()} | {error, list(decode_error())}.
bool(Data) ->
    gleam_stdlib:decode_bool(Data).

-spec shallow_list(dynamic_()) -> {ok, list(dynamic_())} |
    {error, list(decode_error())}.
shallow_list(Value) ->
    gleam_stdlib:decode_list(Value).

-spec optional(fun((dynamic_()) -> {ok, DVA} | {error, list(decode_error())})) -> fun((dynamic_()) -> {ok,
        gleam@option:option(DVA)} |
    {error, list(decode_error())}).
optional(Decode) ->
    fun(Value) -> gleam_stdlib:decode_option(Value, Decode) end.

-spec at_least_decode_tuple_error(integer(), dynamic_()) -> {ok, any()} |
    {error, list(decode_error())}.
at_least_decode_tuple_error(Size, Data) ->
    S = case Size of
        1 ->
            <<""/utf8>>;

        _ ->
            <<"s"/utf8>>
    end,
    Error = begin
        _pipe = [<<"Tuple of at least "/utf8>>,
            gleam@int:to_string(Size),
            <<" element"/utf8>>,
            S],
        _pipe@1 = gleam@string_builder:from_strings(_pipe),
        _pipe@2 = gleam@string_builder:to_string(_pipe@1),
        {decode_error, _pipe@2, classify(Data), []}
    end,
    {error, [Error]}.

-spec any(list(fun((dynamic_()) -> {ok, DZH} | {error, list(decode_error())}))) -> fun((dynamic_()) -> {ok,
        DZH} |
    {error, list(decode_error())}).
any(Decoders) ->
    fun(Data) -> case Decoders of
            [] ->
                {error,
                    [{decode_error, <<"another type"/utf8>>, classify(Data), []}]};

            [Decoder | Decoders@1] ->
                case Decoder(Data) of
                    {ok, Decoded} ->
                        {ok, Decoded};

                    {error, _} ->
                        (any(Decoders@1))(Data)
                end
        end end.

-spec all_errors({ok, any()} | {error, list(decode_error())}) -> list(decode_error()).
all_errors(Result) ->
    case Result of
        {ok, _} ->
            [];

        {error, Errors} ->
            Errors
    end.

-spec decode1(
    fun((DZL) -> DZM),
    fun((dynamic_()) -> {ok, DZL} | {error, list(decode_error())})
) -> fun((dynamic_()) -> {ok, DZM} | {error, list(decode_error())}).
decode1(Constructor, T1) ->
    fun(Value) -> case T1(Value) of
            {ok, A} ->
                {ok, Constructor(A)};

            A@1 ->
                {error, all_errors(A@1)}
        end end.

-spec push_path(decode_error(), any()) -> decode_error().
push_path(Error, Name) ->
    Name@1 = from(Name),
    Decoder = any(
        [fun string/1,
            fun(X) -> gleam@result:map(int(X), fun gleam@int:to_string/1) end]
    ),
    Name@3 = case Decoder(Name@1) of
        {ok, Name@2} ->
            Name@2;

        {error, _} ->
            _pipe = [<<"<"/utf8>>, classify(Name@1), <<">"/utf8>>],
            _pipe@1 = gleam@string_builder:from_strings(_pipe),
            gleam@string_builder:to_string(_pipe@1)
    end,
    erlang:setelement(4, Error, [Name@3 | erlang:element(4, Error)]).

-spec result(
    fun((dynamic_()) -> {ok, DUO} | {error, list(decode_error())}),
    fun((dynamic_()) -> {ok, DUQ} | {error, list(decode_error())})
) -> fun((dynamic_()) -> {ok, {ok, DUO} | {error, DUQ}} |
    {error, list(decode_error())}).
result(Decode_ok, Decode_error) ->
    fun(Value) ->
        gleam@result:'try'(
            gleam_stdlib:decode_result(Value),
            fun(Inner_result) -> case Inner_result of
                    {ok, Raw} ->
                        gleam@result:'try'(
                            begin
                                _pipe = Decode_ok(Raw),
                                map_errors(
                                    _pipe,
                                    fun(_capture) ->
                                        push_path(_capture, <<"ok"/utf8>>)
                                    end
                                )
                            end,
                            fun(Value@1) -> {ok, {ok, Value@1}} end
                        );

                    {error, Raw@1} ->
                        gleam@result:'try'(
                            begin
                                _pipe@1 = Decode_error(Raw@1),
                                map_errors(
                                    _pipe@1,
                                    fun(_capture@1) ->
                                        push_path(_capture@1, <<"error"/utf8>>)
                                    end
                                )
                            end,
                            fun(Value@2) -> {ok, {error, Value@2}} end
                        )
                end end
        )
    end.

-spec list(fun((dynamic_()) -> {ok, DUV} | {error, list(decode_error())})) -> fun((dynamic_()) -> {ok,
        list(DUV)} |
    {error, list(decode_error())}).
list(Decoder_type) ->
    fun(Dynamic) ->
        gleam@result:'try'(shallow_list(Dynamic), fun(List) -> _pipe = List,
                _pipe@1 = gleam@list:try_map(_pipe, Decoder_type),
                map_errors(
                    _pipe@1,
                    fun(_capture) -> push_path(_capture, <<"*"/utf8>>) end
                ) end)
    end.

-spec map_errors(
    {ok, DTJ} | {error, list(decode_error())},
    fun((decode_error()) -> decode_error())
) -> {ok, DTJ} | {error, list(decode_error())}.
map_errors(Result, F) ->
    gleam@result:map_error(
        Result,
        fun(_capture) -> gleam@list:map(_capture, F) end
    ).

-spec decode_string(dynamic_()) -> {ok, binary()} |
    {error, list(decode_error())}.
decode_string(Data) ->
    _pipe = bit_array(Data),
    _pipe@1 = map_errors(
        _pipe,
        fun(_capture) -> put_expected(_capture, <<"String"/utf8>>) end
    ),
    gleam@result:'try'(
        _pipe@1,
        fun(Raw) -> case gleam@bit_array:to_string(Raw) of
                {ok, String} ->
                    {ok, String};

                {error, nil} ->
                    {error,
                        [{decode_error,
                                <<"String"/utf8>>,
                                <<"BitArray"/utf8>>,
                                []}]}
            end end
    ).

-spec string(dynamic_()) -> {ok, binary()} | {error, list(decode_error())}.
string(Data) ->
    decode_string(Data).

-spec field(
    any(),
    fun((dynamic_()) -> {ok, DVK} | {error, list(decode_error())})
) -> fun((dynamic_()) -> {ok, DVK} | {error, list(decode_error())}).
field(Name, Inner_type) ->
    fun(Value) ->
        Missing_field_error = {decode_error,
            <<"field"/utf8>>,
            <<"nothing"/utf8>>,
            []},
        gleam@result:'try'(
            gleam_stdlib:decode_field(Value, Name),
            fun(Maybe_inner) -> _pipe = Maybe_inner,
                _pipe@1 = gleam@option:to_result(_pipe, [Missing_field_error]),
                _pipe@2 = gleam@result:'try'(_pipe@1, Inner_type),
                map_errors(
                    _pipe@2,
                    fun(_capture) -> push_path(_capture, Name) end
                ) end
        )
    end.

-spec optional_field(
    any(),
    fun((dynamic_()) -> {ok, DVO} | {error, list(decode_error())})
) -> fun((dynamic_()) -> {ok, gleam@option:option(DVO)} |
    {error, list(decode_error())}).
optional_field(Name, Inner_type) ->
    fun(Value) ->
        gleam@result:'try'(
            gleam_stdlib:decode_field(Value, Name),
            fun(Maybe_inner) -> case Maybe_inner of
                    none ->
                        {ok, none};

                    {some, Dynamic_inner} ->
                        _pipe = Dynamic_inner,
                        _pipe@1 = gleam_stdlib:decode_option(_pipe, Inner_type),
                        map_errors(
                            _pipe@1,
                            fun(_capture) -> push_path(_capture, Name) end
                        )
                end end
        )
    end.

-spec element(
    integer(),
    fun((dynamic_()) -> {ok, DVW} | {error, list(decode_error())})
) -> fun((dynamic_()) -> {ok, DVW} | {error, list(decode_error())}).
element(Index, Inner_type) ->
    fun(Data) ->
        gleam@result:'try'(
            gleam_stdlib:decode_tuple(Data),
            fun(Tuple) ->
                Size = gleam_stdlib:size_of_tuple(Tuple),
                gleam@result:'try'(case Index >= 0 of
                        true ->
                            case Index < Size of
                                true ->
                                    gleam_stdlib:tuple_get(Tuple, Index);

                                false ->
                                    at_least_decode_tuple_error(Index + 1, Data)
                            end;

                        false ->
                            case gleam@int:absolute_value(Index) =< Size of
                                true ->
                                    gleam_stdlib:tuple_get(Tuple, Size + Index);

                                false ->
                                    at_least_decode_tuple_error(
                                        gleam@int:absolute_value(Index),
                                        Data
                                    )
                            end
                    end, fun(Data@1) -> _pipe = Inner_type(Data@1),
                        map_errors(
                            _pipe,
                            fun(_capture) -> push_path(_capture, Index) end
                        ) end)
            end
        )
    end.

-spec tuple_errors({ok, any()} | {error, list(decode_error())}, binary()) -> list(decode_error()).
tuple_errors(Result, Name) ->
    case Result of
        {ok, _} ->
            [];

        {error, Errors} ->
            gleam@list:map(
                Errors,
                fun(_capture) -> push_path(_capture, Name) end
            )
    end.

-spec tuple2(
    fun((dynamic_()) -> {ok, DWW} | {error, list(decode_error())}),
    fun((dynamic_()) -> {ok, DWY} | {error, list(decode_error())})
) -> fun((dynamic_()) -> {ok, {DWW, DWY}} | {error, list(decode_error())}).
tuple2(Decode1, Decode2) ->
    fun(Value) ->
        gleam@result:'try'(
            gleam_stdlib:decode_tuple2(Value),
            fun(_use0) ->
                {A, B} = _use0,
                case {Decode1(A), Decode2(B)} of
                    {{ok, A@1}, {ok, B@1}} ->
                        {ok, {A@1, B@1}};

                    {A@2, B@2} ->
                        _pipe = tuple_errors(A@2, <<"0"/utf8>>),
                        _pipe@1 = gleam@list:append(
                            _pipe,
                            tuple_errors(B@2, <<"1"/utf8>>)
                        ),
                        {error, _pipe@1}
                end
            end
        )
    end.

-spec tuple3(
    fun((dynamic_()) -> {ok, DXB} | {error, list(decode_error())}),
    fun((dynamic_()) -> {ok, DXD} | {error, list(decode_error())}),
    fun((dynamic_()) -> {ok, DXF} | {error, list(decode_error())})
) -> fun((dynamic_()) -> {ok, {DXB, DXD, DXF}} | {error, list(decode_error())}).
tuple3(Decode1, Decode2, Decode3) ->
    fun(Value) ->
        gleam@result:'try'(
            gleam_stdlib:decode_tuple3(Value),
            fun(_use0) ->
                {A, B, C} = _use0,
                case {Decode1(A), Decode2(B), Decode3(C)} of
                    {{ok, A@1}, {ok, B@1}, {ok, C@1}} ->
                        {ok, {A@1, B@1, C@1}};

                    {A@2, B@2, C@2} ->
                        _pipe = tuple_errors(A@2, <<"0"/utf8>>),
                        _pipe@1 = gleam@list:append(
                            _pipe,
                            tuple_errors(B@2, <<"1"/utf8>>)
                        ),
                        _pipe@2 = gleam@list:append(
                            _pipe@1,
                            tuple_errors(C@2, <<"2"/utf8>>)
                        ),
                        {error, _pipe@2}
                end
            end
        )
    end.

-spec tuple4(
    fun((dynamic_()) -> {ok, DXI} | {error, list(decode_error())}),
    fun((dynamic_()) -> {ok, DXK} | {error, list(decode_error())}),
    fun((dynamic_()) -> {ok, DXM} | {error, list(decode_error())}),
    fun((dynamic_()) -> {ok, DXO} | {error, list(decode_error())})
) -> fun((dynamic_()) -> {ok, {DXI, DXK, DXM, DXO}} |
    {error, list(decode_error())}).
tuple4(Decode1, Decode2, Decode3, Decode4) ->
    fun(Value) ->
        gleam@result:'try'(
            gleam_stdlib:decode_tuple4(Value),
            fun(_use0) ->
                {A, B, C, D} = _use0,
                case {Decode1(A), Decode2(B), Decode3(C), Decode4(D)} of
                    {{ok, A@1}, {ok, B@1}, {ok, C@1}, {ok, D@1}} ->
                        {ok, {A@1, B@1, C@1, D@1}};

                    {A@2, B@2, C@2, D@2} ->
                        _pipe = tuple_errors(A@2, <<"0"/utf8>>),
                        _pipe@1 = gleam@list:append(
                            _pipe,
                            tuple_errors(B@2, <<"1"/utf8>>)
                        ),
                        _pipe@2 = gleam@list:append(
                            _pipe@1,
                            tuple_errors(C@2, <<"2"/utf8>>)
                        ),
                        _pipe@3 = gleam@list:append(
                            _pipe@2,
                            tuple_errors(D@2, <<"3"/utf8>>)
                        ),
                        {error, _pipe@3}
                end
            end
        )
    end.

-spec tuple5(
    fun((dynamic_()) -> {ok, DXR} | {error, list(decode_error())}),
    fun((dynamic_()) -> {ok, DXT} | {error, list(decode_error())}),
    fun((dynamic_()) -> {ok, DXV} | {error, list(decode_error())}),
    fun((dynamic_()) -> {ok, DXX} | {error, list(decode_error())}),
    fun((dynamic_()) -> {ok, DXZ} | {error, list(decode_error())})
) -> fun((dynamic_()) -> {ok, {DXR, DXT, DXV, DXX, DXZ}} |
    {error, list(decode_error())}).
tuple5(Decode1, Decode2, Decode3, Decode4, Decode5) ->
    fun(Value) ->
        gleam@result:'try'(
            gleam_stdlib:decode_tuple5(Value),
            fun(_use0) ->
                {A, B, C, D, E} = _use0,
                case {Decode1(A),
                    Decode2(B),
                    Decode3(C),
                    Decode4(D),
                    Decode5(E)} of
                    {{ok, A@1}, {ok, B@1}, {ok, C@1}, {ok, D@1}, {ok, E@1}} ->
                        {ok, {A@1, B@1, C@1, D@1, E@1}};

                    {A@2, B@2, C@2, D@2, E@2} ->
                        _pipe = tuple_errors(A@2, <<"0"/utf8>>),
                        _pipe@1 = gleam@list:append(
                            _pipe,
                            tuple_errors(B@2, <<"1"/utf8>>)
                        ),
                        _pipe@2 = gleam@list:append(
                            _pipe@1,
                            tuple_errors(C@2, <<"2"/utf8>>)
                        ),
                        _pipe@3 = gleam@list:append(
                            _pipe@2,
                            tuple_errors(D@2, <<"3"/utf8>>)
                        ),
                        _pipe@4 = gleam@list:append(
                            _pipe@3,
                            tuple_errors(E@2, <<"4"/utf8>>)
                        ),
                        {error, _pipe@4}
                end
            end
        )
    end.

-spec tuple6(
    fun((dynamic_()) -> {ok, DYC} | {error, list(decode_error())}),
    fun((dynamic_()) -> {ok, DYE} | {error, list(decode_error())}),
    fun((dynamic_()) -> {ok, DYG} | {error, list(decode_error())}),
    fun((dynamic_()) -> {ok, DYI} | {error, list(decode_error())}),
    fun((dynamic_()) -> {ok, DYK} | {error, list(decode_error())}),
    fun((dynamic_()) -> {ok, DYM} | {error, list(decode_error())})
) -> fun((dynamic_()) -> {ok, {DYC, DYE, DYG, DYI, DYK, DYM}} |
    {error, list(decode_error())}).
tuple6(Decode1, Decode2, Decode3, Decode4, Decode5, Decode6) ->
    fun(Value) ->
        gleam@result:'try'(
            gleam_stdlib:decode_tuple6(Value),
            fun(_use0) ->
                {A, B, C, D, E, F} = _use0,
                case {Decode1(A),
                    Decode2(B),
                    Decode3(C),
                    Decode4(D),
                    Decode5(E),
                    Decode6(F)} of
                    {{ok, A@1},
                        {ok, B@1},
                        {ok, C@1},
                        {ok, D@1},
                        {ok, E@1},
                        {ok, F@1}} ->
                        {ok, {A@1, B@1, C@1, D@1, E@1, F@1}};

                    {A@2, B@2, C@2, D@2, E@2, F@2} ->
                        _pipe = tuple_errors(A@2, <<"0"/utf8>>),
                        _pipe@1 = gleam@list:append(
                            _pipe,
                            tuple_errors(B@2, <<"1"/utf8>>)
                        ),
                        _pipe@2 = gleam@list:append(
                            _pipe@1,
                            tuple_errors(C@2, <<"2"/utf8>>)
                        ),
                        _pipe@3 = gleam@list:append(
                            _pipe@2,
                            tuple_errors(D@2, <<"3"/utf8>>)
                        ),
                        _pipe@4 = gleam@list:append(
                            _pipe@3,
                            tuple_errors(E@2, <<"4"/utf8>>)
                        ),
                        _pipe@5 = gleam@list:append(
                            _pipe@4,
                            tuple_errors(F@2, <<"5"/utf8>>)
                        ),
                        {error, _pipe@5}
                end
            end
        )
    end.

-spec dict(
    fun((dynamic_()) -> {ok, DYP} | {error, list(decode_error())}),
    fun((dynamic_()) -> {ok, DYR} | {error, list(decode_error())})
) -> fun((dynamic_()) -> {ok, gleam@dict:dict(DYP, DYR)} |
    {error, list(decode_error())}).
dict(Key_type, Value_type) ->
    fun(Value) ->
        gleam@result:'try'(
            gleam_stdlib:decode_map(Value),
            fun(Map) ->
                gleam@result:'try'(
                    begin
                        _pipe = Map,
                        _pipe@1 = gleam@dict:to_list(_pipe),
                        gleam@list:try_map(
                            _pipe@1,
                            fun(Pair) ->
                                {K, V} = Pair,
                                gleam@result:'try'(
                                    begin
                                        _pipe@2 = Key_type(K),
                                        map_errors(
                                            _pipe@2,
                                            fun(_capture) ->
                                                push_path(
                                                    _capture,
                                                    <<"keys"/utf8>>
                                                )
                                            end
                                        )
                                    end,
                                    fun(K@1) ->
                                        gleam@result:'try'(
                                            begin
                                                _pipe@3 = Value_type(V),
                                                map_errors(
                                                    _pipe@3,
                                                    fun(_capture@1) ->
                                                        push_path(
                                                            _capture@1,
                                                            <<"values"/utf8>>
                                                        )
                                                    end
                                                )
                                            end,
                                            fun(V@1) -> {ok, {K@1, V@1}} end
                                        )
                                    end
                                )
                            end
                        )
                    end,
                    fun(Pairs) -> {ok, gleam@dict:from_list(Pairs)} end
                )
            end
        )
    end.

-spec map(
    fun((dynamic_()) -> {ok, DYW} | {error, list(decode_error())}),
    fun((dynamic_()) -> {ok, DYY} | {error, list(decode_error())})
) -> fun((dynamic_()) -> {ok, gleam@dict:dict(DYW, DYY)} |
    {error, list(decode_error())}).
map(Key_type, Value_type) ->
    dict(Key_type, Value_type).

-spec decode2(
    fun((DZP, DZQ) -> DZR),
    fun((dynamic_()) -> {ok, DZP} | {error, list(decode_error())}),
    fun((dynamic_()) -> {ok, DZQ} | {error, list(decode_error())})
) -> fun((dynamic_()) -> {ok, DZR} | {error, list(decode_error())}).
decode2(Constructor, T1, T2) ->
    fun(Value) -> case {T1(Value), T2(Value)} of
            {{ok, A}, {ok, B}} ->
                {ok, Constructor(A, B)};

            {A@1, B@1} ->
                {error, gleam@list:concat([all_errors(A@1), all_errors(B@1)])}
        end end.

-spec decode3(
    fun((DZV, DZW, DZX) -> DZY),
    fun((dynamic_()) -> {ok, DZV} | {error, list(decode_error())}),
    fun((dynamic_()) -> {ok, DZW} | {error, list(decode_error())}),
    fun((dynamic_()) -> {ok, DZX} | {error, list(decode_error())})
) -> fun((dynamic_()) -> {ok, DZY} | {error, list(decode_error())}).
decode3(Constructor, T1, T2, T3) ->
    fun(Value) -> case {T1(Value), T2(Value), T3(Value)} of
            {{ok, A}, {ok, B}, {ok, C}} ->
                {ok, Constructor(A, B, C)};

            {A@1, B@1, C@1} ->
                {error,
                    gleam@list:concat(
                        [all_errors(A@1), all_errors(B@1), all_errors(C@1)]
                    )}
        end end.

-spec decode4(
    fun((EAD, EAE, EAF, EAG) -> EAH),
    fun((dynamic_()) -> {ok, EAD} | {error, list(decode_error())}),
    fun((dynamic_()) -> {ok, EAE} | {error, list(decode_error())}),
    fun((dynamic_()) -> {ok, EAF} | {error, list(decode_error())}),
    fun((dynamic_()) -> {ok, EAG} | {error, list(decode_error())})
) -> fun((dynamic_()) -> {ok, EAH} | {error, list(decode_error())}).
decode4(Constructor, T1, T2, T3, T4) ->
    fun(X) -> case {T1(X), T2(X), T3(X), T4(X)} of
            {{ok, A}, {ok, B}, {ok, C}, {ok, D}} ->
                {ok, Constructor(A, B, C, D)};

            {A@1, B@1, C@1, D@1} ->
                {error,
                    gleam@list:concat(
                        [all_errors(A@1),
                            all_errors(B@1),
                            all_errors(C@1),
                            all_errors(D@1)]
                    )}
        end end.

-spec decode5(
    fun((EAN, EAO, EAP, EAQ, EAR) -> EAS),
    fun((dynamic_()) -> {ok, EAN} | {error, list(decode_error())}),
    fun((dynamic_()) -> {ok, EAO} | {error, list(decode_error())}),
    fun((dynamic_()) -> {ok, EAP} | {error, list(decode_error())}),
    fun((dynamic_()) -> {ok, EAQ} | {error, list(decode_error())}),
    fun((dynamic_()) -> {ok, EAR} | {error, list(decode_error())})
) -> fun((dynamic_()) -> {ok, EAS} | {error, list(decode_error())}).
decode5(Constructor, T1, T2, T3, T4, T5) ->
    fun(X) -> case {T1(X), T2(X), T3(X), T4(X), T5(X)} of
            {{ok, A}, {ok, B}, {ok, C}, {ok, D}, {ok, E}} ->
                {ok, Constructor(A, B, C, D, E)};

            {A@1, B@1, C@1, D@1, E@1} ->
                {error,
                    gleam@list:concat(
                        [all_errors(A@1),
                            all_errors(B@1),
                            all_errors(C@1),
                            all_errors(D@1),
                            all_errors(E@1)]
                    )}
        end end.

-spec decode6(
    fun((EAZ, EBA, EBB, EBC, EBD, EBE) -> EBF),
    fun((dynamic_()) -> {ok, EAZ} | {error, list(decode_error())}),
    fun((dynamic_()) -> {ok, EBA} | {error, list(decode_error())}),
    fun((dynamic_()) -> {ok, EBB} | {error, list(decode_error())}),
    fun((dynamic_()) -> {ok, EBC} | {error, list(decode_error())}),
    fun((dynamic_()) -> {ok, EBD} | {error, list(decode_error())}),
    fun((dynamic_()) -> {ok, EBE} | {error, list(decode_error())})
) -> fun((dynamic_()) -> {ok, EBF} | {error, list(decode_error())}).
decode6(Constructor, T1, T2, T3, T4, T5, T6) ->
    fun(X) -> case {T1(X), T2(X), T3(X), T4(X), T5(X), T6(X)} of
            {{ok, A}, {ok, B}, {ok, C}, {ok, D}, {ok, E}, {ok, F}} ->
                {ok, Constructor(A, B, C, D, E, F)};

            {A@1, B@1, C@1, D@1, E@1, F@1} ->
                {error,
                    gleam@list:concat(
                        [all_errors(A@1),
                            all_errors(B@1),
                            all_errors(C@1),
                            all_errors(D@1),
                            all_errors(E@1),
                            all_errors(F@1)]
                    )}
        end end.

-spec decode7(
    fun((EBN, EBO, EBP, EBQ, EBR, EBS, EBT) -> EBU),
    fun((dynamic_()) -> {ok, EBN} | {error, list(decode_error())}),
    fun((dynamic_()) -> {ok, EBO} | {error, list(decode_error())}),
    fun((dynamic_()) -> {ok, EBP} | {error, list(decode_error())}),
    fun((dynamic_()) -> {ok, EBQ} | {error, list(decode_error())}),
    fun((dynamic_()) -> {ok, EBR} | {error, list(decode_error())}),
    fun((dynamic_()) -> {ok, EBS} | {error, list(decode_error())}),
    fun((dynamic_()) -> {ok, EBT} | {error, list(decode_error())})
) -> fun((dynamic_()) -> {ok, EBU} | {error, list(decode_error())}).
decode7(Constructor, T1, T2, T3, T4, T5, T6, T7) ->
    fun(X) -> case {T1(X), T2(X), T3(X), T4(X), T5(X), T6(X), T7(X)} of
            {{ok, A}, {ok, B}, {ok, C}, {ok, D}, {ok, E}, {ok, F}, {ok, G}} ->
                {ok, Constructor(A, B, C, D, E, F, G)};

            {A@1, B@1, C@1, D@1, E@1, F@1, G@1} ->
                {error,
                    gleam@list:concat(
                        [all_errors(A@1),
                            all_errors(B@1),
                            all_errors(C@1),
                            all_errors(D@1),
                            all_errors(E@1),
                            all_errors(F@1),
                            all_errors(G@1)]
                    )}
        end end.

-spec decode8(
    fun((ECD, ECE, ECF, ECG, ECH, ECI, ECJ, ECK) -> ECL),
    fun((dynamic_()) -> {ok, ECD} | {error, list(decode_error())}),
    fun((dynamic_()) -> {ok, ECE} | {error, list(decode_error())}),
    fun((dynamic_()) -> {ok, ECF} | {error, list(decode_error())}),
    fun((dynamic_()) -> {ok, ECG} | {error, list(decode_error())}),
    fun((dynamic_()) -> {ok, ECH} | {error, list(decode_error())}),
    fun((dynamic_()) -> {ok, ECI} | {error, list(decode_error())}),
    fun((dynamic_()) -> {ok, ECJ} | {error, list(decode_error())}),
    fun((dynamic_()) -> {ok, ECK} | {error, list(decode_error())})
) -> fun((dynamic_()) -> {ok, ECL} | {error, list(decode_error())}).
decode8(Constructor, T1, T2, T3, T4, T5, T6, T7, T8) ->
    fun(X) -> case {T1(X), T2(X), T3(X), T4(X), T5(X), T6(X), T7(X), T8(X)} of
            {{ok, A},
                {ok, B},
                {ok, C},
                {ok, D},
                {ok, E},
                {ok, F},
                {ok, G},
                {ok, H}} ->
                {ok, Constructor(A, B, C, D, E, F, G, H)};

            {A@1, B@1, C@1, D@1, E@1, F@1, G@1, H@1} ->
                {error,
                    gleam@list:concat(
                        [all_errors(A@1),
                            all_errors(B@1),
                            all_errors(C@1),
                            all_errors(D@1),
                            all_errors(E@1),
                            all_errors(F@1),
                            all_errors(G@1),
                            all_errors(H@1)]
                    )}
        end end.

-spec decode9(
    fun((ECV, ECW, ECX, ECY, ECZ, EDA, EDB, EDC, EDD) -> EDE),
    fun((dynamic_()) -> {ok, ECV} | {error, list(decode_error())}),
    fun((dynamic_()) -> {ok, ECW} | {error, list(decode_error())}),
    fun((dynamic_()) -> {ok, ECX} | {error, list(decode_error())}),
    fun((dynamic_()) -> {ok, ECY} | {error, list(decode_error())}),
    fun((dynamic_()) -> {ok, ECZ} | {error, list(decode_error())}),
    fun((dynamic_()) -> {ok, EDA} | {error, list(decode_error())}),
    fun((dynamic_()) -> {ok, EDB} | {error, list(decode_error())}),
    fun((dynamic_()) -> {ok, EDC} | {error, list(decode_error())}),
    fun((dynamic_()) -> {ok, EDD} | {error, list(decode_error())})
) -> fun((dynamic_()) -> {ok, EDE} | {error, list(decode_error())}).
decode9(Constructor, T1, T2, T3, T4, T5, T6, T7, T8, T9) ->
    fun(X) ->
        case {T1(X), T2(X), T3(X), T4(X), T5(X), T6(X), T7(X), T8(X), T9(X)} of
            {{ok, A},
                {ok, B},
                {ok, C},
                {ok, D},
                {ok, E},
                {ok, F},
                {ok, G},
                {ok, H},
                {ok, I}} ->
                {ok, Constructor(A, B, C, D, E, F, G, H, I)};

            {A@1, B@1, C@1, D@1, E@1, F@1, G@1, H@1, I@1} ->
                {error,
                    gleam@list:concat(
                        [all_errors(A@1),
                            all_errors(B@1),
                            all_errors(C@1),
                            all_errors(D@1),
                            all_errors(E@1),
                            all_errors(F@1),
                            all_errors(G@1),
                            all_errors(H@1),
                            all_errors(I@1)]
                    )}
        end
    end.

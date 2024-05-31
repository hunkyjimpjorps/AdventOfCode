-module(gleam@http@response).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function]).

-export([new/1, get_header/2, set_header/3, prepend_header/3, set_body/2, try_map/2, map/2, redirect/1, get_cookies/1, set_cookie/4, expire_cookie/3]).
-export_type([response/1]).

-type response(GFN) :: {response, integer(), list({binary(), binary()}), GFN}.

-spec new(integer()) -> response(binary()).
new(Status) ->
    {response, Status, [], <<""/utf8>>}.

-spec get_header(response(any()), binary()) -> {ok, binary()} | {error, nil}.
get_header(Response, Key) ->
    gleam@list:key_find(
        erlang:element(3, Response),
        gleam@string:lowercase(Key)
    ).

-spec set_header(response(GGC), binary(), binary()) -> response(GGC).
set_header(Response, Key, Value) ->
    Headers = gleam@list:key_set(
        erlang:element(3, Response),
        gleam@string:lowercase(Key),
        Value
    ),
    erlang:setelement(3, Response, Headers).

-spec prepend_header(response(GGF), binary(), binary()) -> response(GGF).
prepend_header(Response, Key, Value) ->
    Headers = [{gleam@string:lowercase(Key), Value} |
        erlang:element(3, Response)],
    erlang:setelement(3, Response, Headers).

-spec set_body(response(any()), GGK) -> response(GGK).
set_body(Response, Body) ->
    {response, Status, Headers, _} = Response,
    {response, Status, Headers, Body}.

-spec try_map(response(GFO), fun((GFO) -> {ok, GFQ} | {error, GFR})) -> {ok,
        response(GFQ)} |
    {error, GFR}.
try_map(Response, Transform) ->
    gleam@result:then(
        Transform(erlang:element(4, Response)),
        fun(Body) -> {ok, set_body(Response, Body)} end
    ).

-spec map(response(GGM), fun((GGM) -> GGO)) -> response(GGO).
map(Response, Transform) ->
    _pipe = erlang:element(4, Response),
    _pipe@1 = Transform(_pipe),
    set_body(Response, _pipe@1).

-spec redirect(binary()) -> response(binary()).
redirect(Uri) ->
    {response,
        303,
        [{<<"location"/utf8>>, Uri}],
        gleam@string:append(<<"You are being redirected to "/utf8>>, Uri)}.

-spec get_cookies(response(any())) -> list({binary(), binary()}).
get_cookies(Resp) ->
    {response, _, Headers, _} = Resp,
    _pipe = Headers,
    _pipe@1 = gleam@list:filter_map(
        _pipe,
        fun(Header) ->
            {Name, Value} = Header,
            case Name of
                <<"set-cookie"/utf8>> ->
                    {ok, gleam@http@cookie:parse(Value)};

                _ ->
                    {error, nil}
            end
        end
    ),
    gleam@list:flatten(_pipe@1).

-spec set_cookie(
    response(GGT),
    binary(),
    binary(),
    gleam@http@cookie:attributes()
) -> response(GGT).
set_cookie(Response, Name, Value, Attributes) ->
    prepend_header(
        Response,
        <<"set-cookie"/utf8>>,
        gleam@http@cookie:set_header(Name, Value, Attributes)
    ).

-spec expire_cookie(response(GGW), binary(), gleam@http@cookie:attributes()) -> response(GGW).
expire_cookie(Response, Name, Attributes) ->
    Attrs = erlang:setelement(2, Attributes, {some, 0}),
    set_cookie(Response, Name, <<""/utf8>>, Attrs).

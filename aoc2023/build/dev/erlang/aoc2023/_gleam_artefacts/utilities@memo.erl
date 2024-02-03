-module(utilities@memo).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function]).

-export([create/1, set/3, get/2, memoize/3]).
-export_type([message/2, cache/2]).

-type message(BEO, BEP) :: shutdown |
    {get, BEO, gleam@erlang@process:subject({ok, BEP} | {error, nil})} |
    {set, BEO, BEP}.

-opaque cache(BEQ, BER) :: {cache,
        gleam@erlang@process:subject(message(BEQ, BER))}.

-spec handle_message(message(BEX, BEY), gleam@dict:dict(BEX, BEY)) -> gleam@otp@actor:next(message(BEX, BEY), gleam@dict:dict(BEX, BEY)).
handle_message(Message, Dict) ->
    case Message of
        shutdown ->
            {stop, normal};

        {get, Key, Client} ->
            gleam@erlang@process:send(Client, gleam@dict:get(Dict, Key)),
            {continue, Dict, none};

        {set, Key@1, Value} ->
            {continue, gleam@dict:insert(Dict, Key@1, Value), none}
    end.

-spec create(fun((cache(any(), any())) -> BFN)) -> BFN.
create(Fun) ->
    _assert_subject = gleam@otp@actor:start(
        gleam@dict:new(),
        fun handle_message/2
    ),
    {ok, Server} = case _assert_subject of
        {ok, _} -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail,
                        module => <<"utilities/memo"/utf8>>,
                        function => <<"create"/utf8>>,
                        line => 36})
    end,
    Result = Fun({cache, Server}),
    gleam@erlang@process:send(Server, shutdown),
    Result.

-spec set(cache(BFO, BFP), BFO, BFP) -> nil.
set(Cache, Key, Value) ->
    gleam@erlang@process:send(erlang:element(2, Cache), {set, Key, Value}).

-spec get(cache(BFS, BFT), BFS) -> {ok, BFT} | {error, nil}.
get(Cache, Key) ->
    gleam@erlang@process:call(
        erlang:element(2, Cache),
        fun(C) -> {get, Key, C} end,
        1000
    ).

-spec memoize(cache(BFY, BFZ), BFY, fun(() -> BFZ)) -> BFZ.
memoize(Cache, Key, Fun) ->
    Result = case get(Cache, Key) of
        {ok, Value} ->
            Value;

        {error, nil} ->
            Fun()
    end,
    set(Cache, Key, Result),
    Result.

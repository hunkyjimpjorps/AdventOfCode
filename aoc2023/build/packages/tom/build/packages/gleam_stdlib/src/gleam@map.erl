-module(gleam@map).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch]).

-export([size/1, to_list/1, from_list/1, has_key/2, new/0, get/2, insert/3, map_values/2, keys/1, values/1, filter/2, take/2, merge/2, delete/2, drop/2, update/3, fold/3]).

-spec size(gleam@dict:dict(any(), any())) -> integer().
size(Map) ->
    maps:size(Map).

-spec to_list(gleam@dict:dict(EWQ, EWR)) -> list({EWQ, EWR}).
to_list(Map) ->
    maps:to_list(Map).

-spec from_list(list({EWT, EWU})) -> gleam@dict:dict(EWT, EWU).
from_list(List) ->
    maps:from_list(List).

-spec has_key(gleam@dict:dict(EWY, any()), EWY) -> boolean().
has_key(Map, Key) ->
    gleam@dict:has_key(Map, Key).

-spec new() -> gleam@dict:dict(any(), any()).
new() ->
    gleam@dict:new().

-spec get(gleam@dict:dict(EXB, EXC), EXB) -> {ok, EXC} | {error, nil}.
get(From, Get) ->
    gleam@dict:get(From, Get).

-spec insert(gleam@dict:dict(EXG, EXH), EXG, EXH) -> gleam@dict:dict(EXG, EXH).
insert(Map, Key, Value) ->
    gleam@dict:insert(Map, Key, Value).

-spec map_values(gleam@dict:dict(EXK, EXL), fun((EXK, EXL) -> EXM)) -> gleam@dict:dict(EXK, EXM).
map_values(Map, Fun) ->
    gleam@dict:map_values(Map, Fun).

-spec keys(gleam@dict:dict(EXP, any())) -> list(EXP).
keys(Map) ->
    gleam@dict:keys(Map).

-spec values(gleam@dict:dict(any(), EXS)) -> list(EXS).
values(Map) ->
    gleam@dict:values(Map).

-spec filter(gleam@dict:dict(EXV, EXW), fun((EXV, EXW) -> boolean())) -> gleam@dict:dict(EXV, EXW).
filter(Map, Predicate) ->
    gleam@dict:filter(Map, Predicate).

-spec take(gleam@dict:dict(EXZ, EZT), list(EXZ)) -> gleam@dict:dict(EXZ, EZT).
take(Map, Desired_keys) ->
    gleam@dict:take(Map, Desired_keys).

-spec merge(gleam@dict:dict(EZU, EZV), gleam@dict:dict(EZU, EZV)) -> gleam@dict:dict(EZU, EZV).
merge(Map, New_entries) ->
    gleam@dict:merge(Map, New_entries).

-spec delete(gleam@dict:dict(EYG, EZX), EYG) -> gleam@dict:dict(EYG, EZX).
delete(Map, Key) ->
    gleam@dict:delete(Map, Key).

-spec drop(gleam@dict:dict(EYJ, EZZ), list(EYJ)) -> gleam@dict:dict(EYJ, EZZ).
drop(Map, Disallowed_keys) ->
    gleam@dict:drop(Map, Disallowed_keys).

-spec update(
    gleam@dict:dict(EYN, EYO),
    EYN,
    fun((gleam@option:option(EYO)) -> EYO)
) -> gleam@dict:dict(EYN, EYO).
update(Map, Key, Fun) ->
    gleam@dict:update(Map, Key, Fun).

-spec fold(gleam@dict:dict(EYT, EYU), EYS, fun((EYS, EYT, EYU) -> EYS)) -> EYS.
fold(Map, Initial, Fun) ->
    gleam@dict:fold(Map, Initial, Fun).

-module(gleam@map).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch]).

-export([size/1, to_list/1, from_list/1, has_key/2, new/0, get/2, insert/3, map_values/2, keys/1, values/1, filter/2, take/2, merge/2, delete/2, drop/2, update/3, fold/3]).

-spec size(gleam@dict:dict(any(), any())) -> integer().
size(Map) ->
    gleam@dict:size(Map).

-spec to_list(gleam@dict:dict(CZB, CZC)) -> list({CZB, CZC}).
to_list(Map) ->
    gleam@dict:to_list(Map).

-spec from_list(list({CZE, CZF})) -> gleam@dict:dict(CZE, CZF).
from_list(List) ->
    gleam@dict:from_list(List).

-spec has_key(gleam@dict:dict(CZJ, any()), CZJ) -> boolean().
has_key(Map, Key) ->
    gleam@dict:has_key(Map, Key).

-spec new() -> gleam@dict:dict(any(), any()).
new() ->
    gleam@dict:new().

-spec get(gleam@dict:dict(CZM, CZN), CZM) -> {ok, CZN} | {error, nil}.
get(From, Get) ->
    gleam@dict:get(From, Get).

-spec insert(gleam@dict:dict(CZR, CZS), CZR, CZS) -> gleam@dict:dict(CZR, CZS).
insert(Map, Key, Value) ->
    gleam@dict:insert(Map, Key, Value).

-spec map_values(gleam@dict:dict(CZV, CZW), fun((CZV, CZW) -> CZX)) -> gleam@dict:dict(CZV, CZX).
map_values(Map, Fun) ->
    gleam@dict:map_values(Map, Fun).

-spec keys(gleam@dict:dict(DAA, any())) -> list(DAA).
keys(Map) ->
    gleam@dict:keys(Map).

-spec values(gleam@dict:dict(any(), DAD)) -> list(DAD).
values(Map) ->
    gleam@dict:values(Map).

-spec filter(gleam@dict:dict(DAG, DAH), fun((DAG, DAH) -> boolean())) -> gleam@dict:dict(DAG, DAH).
filter(Map, Predicate) ->
    gleam@dict:filter(Map, Predicate).

-spec take(gleam@dict:dict(DAK, DCE), list(DAK)) -> gleam@dict:dict(DAK, DCE).
take(Map, Desired_keys) ->
    gleam@dict:take(Map, Desired_keys).

-spec merge(gleam@dict:dict(DCF, DCG), gleam@dict:dict(DCF, DCG)) -> gleam@dict:dict(DCF, DCG).
merge(Map, New_entries) ->
    gleam@dict:merge(Map, New_entries).

-spec delete(gleam@dict:dict(DAR, DCI), DAR) -> gleam@dict:dict(DAR, DCI).
delete(Map, Key) ->
    gleam@dict:delete(Map, Key).

-spec drop(gleam@dict:dict(DAU, DCK), list(DAU)) -> gleam@dict:dict(DAU, DCK).
drop(Map, Disallowed_keys) ->
    gleam@dict:drop(Map, Disallowed_keys).

-spec update(
    gleam@dict:dict(DAY, DAZ),
    DAY,
    fun((gleam@option:option(DAZ)) -> DAZ)
) -> gleam@dict:dict(DAY, DAZ).
update(Map, Key, Fun) ->
    gleam@dict:update(Map, Key, Fun).

-spec fold(gleam@dict:dict(DBE, DBF), DBD, fun((DBD, DBE, DBF) -> DBD)) -> DBD.
fold(Map, Initial, Fun) ->
    gleam@dict:fold(Map, Initial, Fun).

-module(gleam@map).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function]).

-export([size/1, to_list/1, from_list/1, has_key/2, new/0, get/2, insert/3, map_values/2, keys/1, values/1, filter/2, take/2, merge/2, delete/2, drop/2, update/3, fold/3]).

-spec size(gleam@dict:dict(any(), any())) -> integer().
size(Map) ->
    gleam@dict:size(Map).

-spec to_list(gleam@dict:dict(DAJ, DAK)) -> list({DAJ, DAK}).
to_list(Map) ->
    gleam@dict:to_list(Map).

-spec from_list(list({DAM, DAN})) -> gleam@dict:dict(DAM, DAN).
from_list(List) ->
    gleam@dict:from_list(List).

-spec has_key(gleam@dict:dict(DAR, any()), DAR) -> boolean().
has_key(Map, Key) ->
    gleam@dict:has_key(Map, Key).

-spec new() -> gleam@dict:dict(any(), any()).
new() ->
    gleam@dict:new().

-spec get(gleam@dict:dict(DAU, DAV), DAU) -> {ok, DAV} | {error, nil}.
get(From, Get) ->
    gleam@dict:get(From, Get).

-spec insert(gleam@dict:dict(DAZ, DBA), DAZ, DBA) -> gleam@dict:dict(DAZ, DBA).
insert(Map, Key, Value) ->
    gleam@dict:insert(Map, Key, Value).

-spec map_values(gleam@dict:dict(DBD, DBE), fun((DBD, DBE) -> DBF)) -> gleam@dict:dict(DBD, DBF).
map_values(Map, Fun) ->
    gleam@dict:map_values(Map, Fun).

-spec keys(gleam@dict:dict(DBI, any())) -> list(DBI).
keys(Map) ->
    gleam@dict:keys(Map).

-spec values(gleam@dict:dict(any(), DBL)) -> list(DBL).
values(Map) ->
    gleam@dict:values(Map).

-spec filter(gleam@dict:dict(DBO, DBP), fun((DBO, DBP) -> boolean())) -> gleam@dict:dict(DBO, DBP).
filter(Map, Predicate) ->
    gleam@dict:filter(Map, Predicate).

-spec take(gleam@dict:dict(DBS, DDM), list(DBS)) -> gleam@dict:dict(DBS, DDM).
take(Map, Desired_keys) ->
    gleam@dict:take(Map, Desired_keys).

-spec merge(gleam@dict:dict(DDN, DDO), gleam@dict:dict(DDN, DDO)) -> gleam@dict:dict(DDN, DDO).
merge(Map, New_entries) ->
    gleam@dict:merge(Map, New_entries).

-spec delete(gleam@dict:dict(DBZ, DDQ), DBZ) -> gleam@dict:dict(DBZ, DDQ).
delete(Map, Key) ->
    gleam@dict:delete(Map, Key).

-spec drop(gleam@dict:dict(DCC, DDS), list(DCC)) -> gleam@dict:dict(DCC, DDS).
drop(Map, Disallowed_keys) ->
    gleam@dict:drop(Map, Disallowed_keys).

-spec update(
    gleam@dict:dict(DCG, DCH),
    DCG,
    fun((gleam@option:option(DCH)) -> DCH)
) -> gleam@dict:dict(DCG, DCH).
update(Map, Key, Fun) ->
    gleam@dict:update(Map, Key, Fun).

-spec fold(gleam@dict:dict(DCM, DCN), DCL, fun((DCL, DCM, DCN) -> DCL)) -> DCL.
fold(Map, Initial, Fun) ->
    gleam@dict:fold(Map, Initial, Fun).

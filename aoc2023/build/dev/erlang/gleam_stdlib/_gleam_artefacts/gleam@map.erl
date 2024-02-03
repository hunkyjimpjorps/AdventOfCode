-module(gleam@map).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function]).

-export([size/1, to_list/1, from_list/1, has_key/2, new/0, get/2, insert/3, map_values/2, keys/1, values/1, filter/2, take/2, merge/2, delete/2, drop/2, update/3, fold/3]).

-spec size(gleam@dict:dict(any(), any())) -> integer().
size(Map) ->
    gleam@dict:size(Map).

-spec to_list(gleam@dict:dict(FDO, FDP)) -> list({FDO, FDP}).
to_list(Map) ->
    gleam@dict:to_list(Map).

-spec from_list(list({FDR, FDS})) -> gleam@dict:dict(FDR, FDS).
from_list(List) ->
    gleam@dict:from_list(List).

-spec has_key(gleam@dict:dict(FDW, any()), FDW) -> boolean().
has_key(Map, Key) ->
    gleam@dict:has_key(Map, Key).

-spec new() -> gleam@dict:dict(any(), any()).
new() ->
    gleam@dict:new().

-spec get(gleam@dict:dict(FDZ, FEA), FDZ) -> {ok, FEA} | {error, nil}.
get(From, Get) ->
    gleam@dict:get(From, Get).

-spec insert(gleam@dict:dict(FEE, FEF), FEE, FEF) -> gleam@dict:dict(FEE, FEF).
insert(Map, Key, Value) ->
    gleam@dict:insert(Map, Key, Value).

-spec map_values(gleam@dict:dict(FEI, FEJ), fun((FEI, FEJ) -> FEK)) -> gleam@dict:dict(FEI, FEK).
map_values(Map, Fun) ->
    gleam@dict:map_values(Map, Fun).

-spec keys(gleam@dict:dict(FEN, any())) -> list(FEN).
keys(Map) ->
    gleam@dict:keys(Map).

-spec values(gleam@dict:dict(any(), FEQ)) -> list(FEQ).
values(Map) ->
    gleam@dict:values(Map).

-spec filter(gleam@dict:dict(FET, FEU), fun((FET, FEU) -> boolean())) -> gleam@dict:dict(FET, FEU).
filter(Map, Predicate) ->
    gleam@dict:filter(Map, Predicate).

-spec take(gleam@dict:dict(FEX, FGR), list(FEX)) -> gleam@dict:dict(FEX, FGR).
take(Map, Desired_keys) ->
    gleam@dict:take(Map, Desired_keys).

-spec merge(gleam@dict:dict(FGS, FGT), gleam@dict:dict(FGS, FGT)) -> gleam@dict:dict(FGS, FGT).
merge(Map, New_entries) ->
    gleam@dict:merge(Map, New_entries).

-spec delete(gleam@dict:dict(FFE, FGV), FFE) -> gleam@dict:dict(FFE, FGV).
delete(Map, Key) ->
    gleam@dict:delete(Map, Key).

-spec drop(gleam@dict:dict(FFH, FGX), list(FFH)) -> gleam@dict:dict(FFH, FGX).
drop(Map, Disallowed_keys) ->
    gleam@dict:drop(Map, Disallowed_keys).

-spec update(
    gleam@dict:dict(FFL, FFM),
    FFL,
    fun((gleam@option:option(FFM)) -> FFM)
) -> gleam@dict:dict(FFL, FFM).
update(Map, Key, Fun) ->
    gleam@dict:update(Map, Key, Fun).

-spec fold(gleam@dict:dict(FFR, FFS), FFQ, fun((FFQ, FFR, FFS) -> FFQ)) -> FFQ.
fold(Map, Initial, Fun) ->
    gleam@dict:fold(Map, Initial, Fun).

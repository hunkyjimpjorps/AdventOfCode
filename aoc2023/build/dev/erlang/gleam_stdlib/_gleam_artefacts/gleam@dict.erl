-module(gleam@dict).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch]).

-export([size/1, to_list/1, from_list/1, has_key/2, new/0, get/2, insert/3, map_values/2, keys/1, values/1, filter/2, take/2, merge/2, delete/2, drop/2, update/3, fold/3]).
-export_type([dict/2]).

-type dict(KS, KT) :: any() | {gleam_phantom, KS, KT}.

-spec size(dict(any(), any())) -> integer().
size(Dict) ->
    maps:size(Dict).

-spec to_list(dict(LC, LD)) -> list({LC, LD}).
to_list(Dict) ->
    maps:to_list(Dict).

-spec from_list(list({LM, LN})) -> dict(LM, LN).
from_list(List) ->
    maps:from_list(List).

-spec has_key(dict(LW, any()), LW) -> boolean().
has_key(Dict, Key) ->
    maps:is_key(Key, Dict).

-spec new() -> dict(any(), any()).
new() ->
    maps:new().

-spec get(dict(MM, MN), MM) -> {ok, MN} | {error, nil}.
get(From, Get) ->
    gleam_stdlib:map_get(From, Get).

-spec insert(dict(MY, MZ), MY, MZ) -> dict(MY, MZ).
insert(Dict, Key, Value) ->
    maps:put(Key, Value, Dict).

-spec map_values(dict(NK, NL), fun((NK, NL) -> NO)) -> dict(NK, NO).
map_values(Dict, Fun) ->
    maps:map(Fun, Dict).

-spec keys(dict(NY, any())) -> list(NY).
keys(Dict) ->
    maps:keys(Dict).

-spec values(dict(any(), OJ)) -> list(OJ).
values(Dict) ->
    maps:values(Dict).

-spec filter(dict(OS, OT), fun((OS, OT) -> boolean())) -> dict(OS, OT).
filter(Dict, Predicate) ->
    maps:filter(Predicate, Dict).

-spec take(dict(PE, PF), list(PE)) -> dict(PE, PF).
take(Dict, Desired_keys) ->
    maps:with(Desired_keys, Dict).

-spec merge(dict(PS, PT), dict(PS, PT)) -> dict(PS, PT).
merge(Dict, New_entries) ->
    maps:merge(Dict, New_entries).

-spec delete(dict(QI, QJ), QI) -> dict(QI, QJ).
delete(Dict, Key) ->
    maps:remove(Key, Dict).

-spec drop(dict(QU, QV), list(QU)) -> dict(QU, QV).
drop(Dict, Disallowed_keys) ->
    case Disallowed_keys of
        [] ->
            Dict;

        [X | Xs] ->
            drop(delete(Dict, X), Xs)
    end.

-spec update(dict(RB, RC), RB, fun((gleam@option:option(RC)) -> RC)) -> dict(RB, RC).
update(Dict, Key, Fun) ->
    _pipe = Dict,
    _pipe@1 = get(_pipe, Key),
    _pipe@2 = gleam@option:from_result(_pipe@1),
    _pipe@3 = Fun(_pipe@2),
    insert(Dict, Key, _pipe@3).

-spec do_fold(list({RI, RJ}), RL, fun((RL, RI, RJ) -> RL)) -> RL.
do_fold(List, Initial, Fun) ->
    case List of
        [] ->
            Initial;

        [{K, V} | Rest] ->
            do_fold(Rest, Fun(Initial, K, V), Fun)
    end.

-spec fold(dict(RM, RN), RQ, fun((RQ, RM, RN) -> RQ)) -> RQ.
fold(Dict, Initial, Fun) ->
    _pipe = Dict,
    _pipe@1 = to_list(_pipe),
    do_fold(_pipe@1, Initial, Fun).

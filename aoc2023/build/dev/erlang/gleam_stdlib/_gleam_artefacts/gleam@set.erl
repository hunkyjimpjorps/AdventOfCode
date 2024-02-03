-module(gleam@set).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function]).

-export([new/0, size/1, insert/2, contains/2, delete/2, to_list/1, from_list/1, fold/3, filter/2, drop/2, take/2, union/2, intersection/2]).
-export_type([set/1]).

-opaque set(EYO) :: {set, gleam@dict:dict(EYO, list(nil))}.

-spec new() -> set(any()).
new() ->
    {set, gleam@dict:new()}.

-spec size(set(any())) -> integer().
size(Set) ->
    gleam@dict:size(erlang:element(2, Set)).

-spec insert(set(EYU), EYU) -> set(EYU).
insert(Set, Member) ->
    {set, gleam@dict:insert(erlang:element(2, Set), Member, [])}.

-spec contains(set(EYX), EYX) -> boolean().
contains(Set, Member) ->
    _pipe = erlang:element(2, Set),
    _pipe@1 = gleam@dict:get(_pipe, Member),
    gleam@result:is_ok(_pipe@1).

-spec delete(set(EYZ), EYZ) -> set(EYZ).
delete(Set, Member) ->
    {set, gleam@dict:delete(erlang:element(2, Set), Member)}.

-spec to_list(set(EZC)) -> list(EZC).
to_list(Set) ->
    gleam@dict:keys(erlang:element(2, Set)).

-spec from_list(list(EZF)) -> set(EZF).
from_list(Members) ->
    Map = gleam@list:fold(
        Members,
        gleam@dict:new(),
        fun(M, K) -> gleam@dict:insert(M, K, []) end
    ),
    {set, Map}.

-spec fold(set(EZI), EZK, fun((EZK, EZI) -> EZK)) -> EZK.
fold(Set, Initial, Reducer) ->
    gleam@dict:fold(
        erlang:element(2, Set),
        Initial,
        fun(A, K, _) -> Reducer(A, K) end
    ).

-spec filter(set(EZL), fun((EZL) -> boolean())) -> set(EZL).
filter(Set, Predicate) ->
    {set,
        gleam@dict:filter(erlang:element(2, Set), fun(M, _) -> Predicate(M) end)}.

-spec drop(set(EZO), list(EZO)) -> set(EZO).
drop(Set, Disallowed) ->
    gleam@list:fold(Disallowed, Set, fun delete/2).

-spec take(set(EZS), list(EZS)) -> set(EZS).
take(Set, Desired) ->
    {set, gleam@dict:take(erlang:element(2, Set), Desired)}.

-spec order(set(EZW), set(EZW)) -> {set(EZW), set(EZW)}.
order(First, Second) ->
    case gleam@dict:size(erlang:element(2, First)) > gleam@dict:size(
        erlang:element(2, Second)
    ) of
        true ->
            {First, Second};

        false ->
            {Second, First}
    end.

-spec union(set(FAB), set(FAB)) -> set(FAB).
union(First, Second) ->
    {Larger, Smaller} = order(First, Second),
    fold(Smaller, Larger, fun insert/2).

-spec intersection(set(FAF), set(FAF)) -> set(FAF).
intersection(First, Second) ->
    {Larger, Smaller} = order(First, Second),
    take(Larger, to_list(Smaller)).

-module(gleam@set).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function]).

-export([new/0, size/1, insert/2, contains/2, delete/2, to_list/1, from_list/1, fold/3, filter/2, drop/2, take/2, union/2, intersection/2]).
-export_type([set/1]).

-opaque set(DJZ) :: {set, gleam@dict:dict(DJZ, list(nil))}.

-spec new() -> set(any()).
new() ->
    {set, gleam@dict:new()}.

-spec size(set(any())) -> integer().
size(Set) ->
    gleam@dict:size(erlang:element(2, Set)).

-spec insert(set(DKF), DKF) -> set(DKF).
insert(Set, Member) ->
    {set, gleam@dict:insert(erlang:element(2, Set), Member, [])}.

-spec contains(set(DKI), DKI) -> boolean().
contains(Set, Member) ->
    _pipe = erlang:element(2, Set),
    _pipe@1 = gleam@dict:get(_pipe, Member),
    gleam@result:is_ok(_pipe@1).

-spec delete(set(DKK), DKK) -> set(DKK).
delete(Set, Member) ->
    {set, gleam@dict:delete(erlang:element(2, Set), Member)}.

-spec to_list(set(DKN)) -> list(DKN).
to_list(Set) ->
    gleam@dict:keys(erlang:element(2, Set)).

-spec from_list(list(DKQ)) -> set(DKQ).
from_list(Members) ->
    Map = gleam@list:fold(
        Members,
        gleam@dict:new(),
        fun(M, K) -> gleam@dict:insert(M, K, []) end
    ),
    {set, Map}.

-spec fold(set(DKT), DKV, fun((DKV, DKT) -> DKV)) -> DKV.
fold(Set, Initial, Reducer) ->
    gleam@dict:fold(
        erlang:element(2, Set),
        Initial,
        fun(A, K, _) -> Reducer(A, K) end
    ).

-spec filter(set(DKW), fun((DKW) -> boolean())) -> set(DKW).
filter(Set, Predicate) ->
    {set,
        gleam@dict:filter(erlang:element(2, Set), fun(M, _) -> Predicate(M) end)}.

-spec drop(set(DKZ), list(DKZ)) -> set(DKZ).
drop(Set, Disallowed) ->
    gleam@list:fold(Disallowed, Set, fun delete/2).

-spec take(set(DLD), list(DLD)) -> set(DLD).
take(Set, Desired) ->
    {set, gleam@dict:take(erlang:element(2, Set), Desired)}.

-spec order(set(DLH), set(DLH)) -> {set(DLH), set(DLH)}.
order(First, Second) ->
    case gleam@dict:size(erlang:element(2, First)) > gleam@dict:size(
        erlang:element(2, Second)
    ) of
        true ->
            {First, Second};

        false ->
            {Second, First}
    end.

-spec union(set(DLM), set(DLM)) -> set(DLM).
union(First, Second) ->
    {Larger, Smaller} = order(First, Second),
    fold(Smaller, Larger, fun insert/2).

-spec intersection(set(DLQ), set(DLQ)) -> set(DLQ).
intersection(First, Second) ->
    {Larger, Smaller} = order(First, Second),
    take(Larger, to_list(Smaller)).

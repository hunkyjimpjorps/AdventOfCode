-module(gleam@set).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch]).

-export([new/0, size/1, contains/2, delete/2, to_list/1, fold/3, filter/2, drop/2, take/2, intersection/2, insert/2, from_list/1, union/2]).
-export_type([set/1]).

-opaque set(DIS) :: {set, gleam@dict:dict(DIS, list(nil))}.

-spec new() -> set(any()).
new() ->
    {set, gleam@dict:new()}.

-spec size(set(any())) -> integer().
size(Set) ->
    gleam@dict:size(erlang:element(2, Set)).

-spec contains(set(DJB), DJB) -> boolean().
contains(Set, Member) ->
    _pipe = erlang:element(2, Set),
    _pipe@1 = gleam@dict:get(_pipe, Member),
    gleam@result:is_ok(_pipe@1).

-spec delete(set(DJD), DJD) -> set(DJD).
delete(Set, Member) ->
    {set, gleam@dict:delete(erlang:element(2, Set), Member)}.

-spec to_list(set(DJG)) -> list(DJG).
to_list(Set) ->
    gleam@dict:keys(erlang:element(2, Set)).

-spec fold(set(DJM), DJO, fun((DJO, DJM) -> DJO)) -> DJO.
fold(Set, Initial, Reducer) ->
    gleam@dict:fold(
        erlang:element(2, Set),
        Initial,
        fun(A, K, _) -> Reducer(A, K) end
    ).

-spec filter(set(DJP), fun((DJP) -> boolean())) -> set(DJP).
filter(Set, Predicate) ->
    {set,
        gleam@dict:filter(erlang:element(2, Set), fun(M, _) -> Predicate(M) end)}.

-spec drop(set(DJS), list(DJS)) -> set(DJS).
drop(Set, Disallowed) ->
    gleam@list:fold(Disallowed, Set, fun delete/2).

-spec take(set(DJW), list(DJW)) -> set(DJW).
take(Set, Desired) ->
    {set, gleam@dict:take(erlang:element(2, Set), Desired)}.

-spec order(set(DKA), set(DKA)) -> {set(DKA), set(DKA)}.
order(First, Second) ->
    case gleam@dict:size(erlang:element(2, First)) > gleam@dict:size(
        erlang:element(2, Second)
    ) of
        true ->
            {First, Second};

        false ->
            {Second, First}
    end.

-spec intersection(set(DKJ), set(DKJ)) -> set(DKJ).
intersection(First, Second) ->
    {Larger, Smaller} = order(First, Second),
    take(Larger, to_list(Smaller)).

-spec insert(set(DIY), DIY) -> set(DIY).
insert(Set, Member) ->
    {set, gleam@dict:insert(erlang:element(2, Set), Member, [])}.

-spec from_list(list(DJJ)) -> set(DJJ).
from_list(Members) ->
    Map = gleam@list:fold(
        Members,
        gleam@dict:new(),
        fun(M, K) -> gleam@dict:insert(M, K, []) end
    ),
    {set, Map}.

-spec union(set(DKF), set(DKF)) -> set(DKF).
union(First, Second) ->
    {Larger, Smaller} = order(First, Second),
    fold(Smaller, Larger, fun insert/2).

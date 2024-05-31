-module(gleam@result).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function]).

-export([is_ok/1, is_error/1, map/2, map_error/2, flatten/1, 'try'/2, then/2, unwrap/2, lazy_unwrap/2, unwrap_error/2, unwrap_both/1, nil_error/1, 'or'/2, lazy_or/2, all/1, partition/1, replace/2, replace_error/2, values/1, try_recover/2]).

-spec is_ok({ok, any()} | {error, any()}) -> boolean().
is_ok(Result) ->
    case Result of
        {error, _} ->
            false;

        {ok, _} ->
            true
    end.

-spec is_error({ok, any()} | {error, any()}) -> boolean().
is_error(Result) ->
    case Result of
        {ok, _} ->
            false;

        {error, _} ->
            true
    end.

-spec map({ok, BFM} | {error, BFN}, fun((BFM) -> BFQ)) -> {ok, BFQ} |
    {error, BFN}.
map(Result, Fun) ->
    case Result of
        {ok, X} ->
            {ok, Fun(X)};

        {error, E} ->
            {error, E}
    end.

-spec map_error({ok, BFT} | {error, BFU}, fun((BFU) -> BFX)) -> {ok, BFT} |
    {error, BFX}.
map_error(Result, Fun) ->
    case Result of
        {ok, X} ->
            {ok, X};

        {error, Error} ->
            {error, Fun(Error)}
    end.

-spec flatten({ok, {ok, BGA} | {error, BGB}} | {error, BGB}) -> {ok, BGA} |
    {error, BGB}.
flatten(Result) ->
    case Result of
        {ok, X} ->
            X;

        {error, Error} ->
            {error, Error}
    end.

-spec 'try'({ok, BGI} | {error, BGJ}, fun((BGI) -> {ok, BGM} | {error, BGJ})) -> {ok,
        BGM} |
    {error, BGJ}.
'try'(Result, Fun) ->
    case Result of
        {ok, X} ->
            Fun(X);

        {error, E} ->
            {error, E}
    end.

-spec then({ok, BGR} | {error, BGS}, fun((BGR) -> {ok, BGV} | {error, BGS})) -> {ok,
        BGV} |
    {error, BGS}.
then(Result, Fun) ->
    'try'(Result, Fun).

-spec unwrap({ok, BHA} | {error, any()}, BHA) -> BHA.
unwrap(Result, Default) ->
    case Result of
        {ok, V} ->
            V;

        {error, _} ->
            Default
    end.

-spec lazy_unwrap({ok, BHE} | {error, any()}, fun(() -> BHE)) -> BHE.
lazy_unwrap(Result, Default) ->
    case Result of
        {ok, V} ->
            V;

        {error, _} ->
            Default()
    end.

-spec unwrap_error({ok, any()} | {error, BHJ}, BHJ) -> BHJ.
unwrap_error(Result, Default) ->
    case Result of
        {ok, _} ->
            Default;

        {error, E} ->
            E
    end.

-spec unwrap_both({ok, BHM} | {error, BHM}) -> BHM.
unwrap_both(Result) ->
    case Result of
        {ok, A} ->
            A;

        {error, A@1} ->
            A@1
    end.

-spec nil_error({ok, BHP} | {error, any()}) -> {ok, BHP} | {error, nil}.
nil_error(Result) ->
    map_error(Result, fun(_) -> nil end).

-spec 'or'({ok, BHV} | {error, BHW}, {ok, BHV} | {error, BHW}) -> {ok, BHV} |
    {error, BHW}.
'or'(First, Second) ->
    case First of
        {ok, _} ->
            First;

        {error, _} ->
            Second
    end.

-spec lazy_or({ok, BID} | {error, BIE}, fun(() -> {ok, BID} | {error, BIE})) -> {ok,
        BID} |
    {error, BIE}.
lazy_or(First, Second) ->
    case First of
        {ok, _} ->
            First;

        {error, _} ->
            Second()
    end.

-spec all(list({ok, BIL} | {error, BIM})) -> {ok, list(BIL)} | {error, BIM}.
all(Results) ->
    gleam@list:try_map(Results, fun(X) -> X end).

-spec do_partition(list({ok, BJA} | {error, BJB}), list(BJA), list(BJB)) -> {list(BJA),
    list(BJB)}.
do_partition(Results, Oks, Errors) ->
    case Results of
        [] ->
            {Oks, Errors};

        [{ok, A} | Rest] ->
            do_partition(Rest, [A | Oks], Errors);

        [{error, E} | Rest@1] ->
            do_partition(Rest@1, Oks, [E | Errors])
    end.

-spec partition(list({ok, BIT} | {error, BIU})) -> {list(BIT), list(BIU)}.
partition(Results) ->
    do_partition(Results, [], []).

-spec replace({ok, any()} | {error, BJJ}, BJM) -> {ok, BJM} | {error, BJJ}.
replace(Result, Value) ->
    case Result of
        {ok, _} ->
            {ok, Value};

        {error, Error} ->
            {error, Error}
    end.

-spec replace_error({ok, BJP} | {error, any()}, BJT) -> {ok, BJP} | {error, BJT}.
replace_error(Result, Error) ->
    case Result of
        {ok, X} ->
            {ok, X};

        {error, _} ->
            {error, Error}
    end.

-spec values(list({ok, BJW} | {error, any()})) -> list(BJW).
values(Results) ->
    gleam@list:filter_map(Results, fun(R) -> R end).

-spec try_recover(
    {ok, BKC} | {error, BKD},
    fun((BKD) -> {ok, BKC} | {error, BKG})
) -> {ok, BKC} | {error, BKG}.
try_recover(Result, Fun) ->
    case Result of
        {ok, Value} ->
            {ok, Value};

        {error, Error} ->
            Fun(Error)
    end.

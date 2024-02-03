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

-spec map({ok, BKA} | {error, BKB}, fun((BKA) -> BKE)) -> {ok, BKE} |
    {error, BKB}.
map(Result, Fun) ->
    case Result of
        {ok, X} ->
            {ok, Fun(X)};

        {error, E} ->
            {error, E}
    end.

-spec map_error({ok, BKH} | {error, BKI}, fun((BKI) -> BKL)) -> {ok, BKH} |
    {error, BKL}.
map_error(Result, Fun) ->
    case Result of
        {ok, X} ->
            {ok, X};

        {error, Error} ->
            {error, Fun(Error)}
    end.

-spec flatten({ok, {ok, BKO} | {error, BKP}} | {error, BKP}) -> {ok, BKO} |
    {error, BKP}.
flatten(Result) ->
    case Result of
        {ok, X} ->
            X;

        {error, Error} ->
            {error, Error}
    end.

-spec 'try'({ok, BKW} | {error, BKX}, fun((BKW) -> {ok, BLA} | {error, BKX})) -> {ok,
        BLA} |
    {error, BKX}.
'try'(Result, Fun) ->
    case Result of
        {ok, X} ->
            Fun(X);

        {error, E} ->
            {error, E}
    end.

-spec then({ok, BLF} | {error, BLG}, fun((BLF) -> {ok, BLJ} | {error, BLG})) -> {ok,
        BLJ} |
    {error, BLG}.
then(Result, Fun) ->
    'try'(Result, Fun).

-spec unwrap({ok, BLO} | {error, any()}, BLO) -> BLO.
unwrap(Result, Default) ->
    case Result of
        {ok, V} ->
            V;

        {error, _} ->
            Default
    end.

-spec lazy_unwrap({ok, BLS} | {error, any()}, fun(() -> BLS)) -> BLS.
lazy_unwrap(Result, Default) ->
    case Result of
        {ok, V} ->
            V;

        {error, _} ->
            Default()
    end.

-spec unwrap_error({ok, any()} | {error, BLX}, BLX) -> BLX.
unwrap_error(Result, Default) ->
    case Result of
        {ok, _} ->
            Default;

        {error, E} ->
            E
    end.

-spec unwrap_both({ok, BMA} | {error, BMA}) -> BMA.
unwrap_both(Result) ->
    case Result of
        {ok, A} ->
            A;

        {error, A@1} ->
            A@1
    end.

-spec nil_error({ok, BMD} | {error, any()}) -> {ok, BMD} | {error, nil}.
nil_error(Result) ->
    map_error(Result, fun(_) -> nil end).

-spec 'or'({ok, BMJ} | {error, BMK}, {ok, BMJ} | {error, BMK}) -> {ok, BMJ} |
    {error, BMK}.
'or'(First, Second) ->
    case First of
        {ok, _} ->
            First;

        {error, _} ->
            Second
    end.

-spec lazy_or({ok, BMR} | {error, BMS}, fun(() -> {ok, BMR} | {error, BMS})) -> {ok,
        BMR} |
    {error, BMS}.
lazy_or(First, Second) ->
    case First of
        {ok, _} ->
            First;

        {error, _} ->
            Second()
    end.

-spec all(list({ok, BMZ} | {error, BNA})) -> {ok, list(BMZ)} | {error, BNA}.
all(Results) ->
    gleam@list:try_map(Results, fun(X) -> X end).

-spec do_partition(list({ok, BNO} | {error, BNP}), list(BNO), list(BNP)) -> {list(BNO),
    list(BNP)}.
do_partition(Results, Oks, Errors) ->
    case Results of
        [] ->
            {Oks, Errors};

        [{ok, A} | Rest] ->
            do_partition(Rest, [A | Oks], Errors);

        [{error, E} | Rest@1] ->
            do_partition(Rest@1, Oks, [E | Errors])
    end.

-spec partition(list({ok, BNH} | {error, BNI})) -> {list(BNH), list(BNI)}.
partition(Results) ->
    do_partition(Results, [], []).

-spec replace({ok, any()} | {error, BNX}, BOA) -> {ok, BOA} | {error, BNX}.
replace(Result, Value) ->
    case Result of
        {ok, _} ->
            {ok, Value};

        {error, Error} ->
            {error, Error}
    end.

-spec replace_error({ok, BOD} | {error, any()}, BOH) -> {ok, BOD} | {error, BOH}.
replace_error(Result, Error) ->
    case Result of
        {ok, X} ->
            {ok, X};

        {error, _} ->
            {error, Error}
    end.

-spec values(list({ok, BOK} | {error, any()})) -> list(BOK).
values(Results) ->
    gleam@list:filter_map(Results, fun(R) -> R end).

-spec try_recover(
    {ok, BOQ} | {error, BOR},
    fun((BOR) -> {ok, BOQ} | {error, BOU})
) -> {ok, BOQ} | {error, BOU}.
try_recover(Result, Fun) ->
    case Result of
        {ok, Value} ->
            {ok, Value};

        {error, Error} ->
            Fun(Error)
    end.

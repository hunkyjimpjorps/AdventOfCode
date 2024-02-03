-module(gleam_community@maths@predicates).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function]).

-export([is_close/4, all_close/4, is_fractional/1, is_power/2, is_perfect/1, is_even/1, is_odd/1]).

-spec float_absolute_value(float()) -> float().
float_absolute_value(X) ->
    case X > +0.0 of
        true ->
            X;

        false ->
            -1.0 * X
    end.

-spec float_absolute_difference(float(), float()) -> float().
float_absolute_difference(A, B) ->
    _pipe = A - B,
    float_absolute_value(_pipe).

-spec is_close(float(), float(), float(), float()) -> boolean().
is_close(A, B, Rtol, Atol) ->
    X = float_absolute_difference(A, B),
    Y = Atol + (Rtol * float_absolute_value(B)),
    case X =< Y of
        true ->
            true;

        false ->
            false
    end.

-spec all_close(list(float()), list(float()), float(), float()) -> {ok,
        list(boolean())} |
    {error, binary()}.
all_close(Xarr, Yarr, Rtol, Atol) ->
    Xlen = gleam@list:length(Xarr),
    Ylen = gleam@list:length(Yarr),
    case Xlen =:= Ylen of
        false ->
            _pipe = <<"Invalid input argument: length(xarr) != length(yarr). Valid input is when length(xarr) == length(yarr)."/utf8>>,
            {error, _pipe};

        true ->
            _pipe@1 = gleam@list:zip(Xarr, Yarr),
            _pipe@2 = gleam@list:map(
                _pipe@1,
                fun(Z) ->
                    is_close(
                        gleam@pair:first(Z),
                        gleam@pair:second(Z),
                        Rtol,
                        Atol
                    )
                end
            ),
            {ok, _pipe@2}
    end.

-spec is_fractional(float()) -> boolean().
is_fractional(X) ->
    (math:ceil(X) - X) > +0.0.

-spec is_power(integer(), integer()) -> boolean().
is_power(X, Y) ->
    _assert_subject = gleam_community@maths@elementary:logarithm(
        gleam@int:to_float(X),
        {some, gleam@int:to_float(Y)}
    ),
    {ok, Value} = case _assert_subject of
        {ok, _} -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail,
                        module => <<"gleam_community/maths/predicates"/utf8>>,
                        function => <<"is_power"/utf8>>,
                        line => 241})
    end,
    _assert_subject@1 = gleam_community@maths@piecewise:truncate(
        Value,
        {some, 0}
    ),
    {ok, Truncated} = case _assert_subject@1 of
        {ok, _} -> _assert_subject@1;
        _assert_fail@1 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail@1,
                        module => <<"gleam_community/maths/predicates"/utf8>>,
                        function => <<"is_power"/utf8>>,
                        line => 243})
    end,
    Rem = Value - Truncated,
    Rem =:= +0.0.

-spec do_sum(list(integer())) -> integer().
do_sum(Arr) ->
    case Arr of
        [] ->
            0;

        _ ->
            _pipe = Arr,
            gleam@list:fold(_pipe, 0, fun(Acc, A) -> A + Acc end)
    end.

-spec is_perfect(integer()) -> boolean().
is_perfect(N) ->
    do_sum(gleam_community@maths@arithmetics:proper_divisors(N)) =:= N.

-spec is_even(integer()) -> boolean().
is_even(X) ->
    (X rem 2) =:= 0.

-spec is_odd(integer()) -> boolean().
is_odd(X) ->
    (X rem 2) /= 0.

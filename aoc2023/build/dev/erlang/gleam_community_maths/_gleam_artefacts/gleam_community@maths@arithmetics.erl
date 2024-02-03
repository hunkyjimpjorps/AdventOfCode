-module(gleam_community@maths@arithmetics).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function]).

-export([gcd/2, lcm/2, divisors/1, proper_divisors/1, float_sum/1, int_sum/1, float_product/1, int_product/1, float_cumulative_sum/1, int_cumulative_sum/1, float_cumumlative_product/1, int_cumulative_product/1]).

-spec do_gcd(integer(), integer()) -> integer().
do_gcd(X, Y) ->
    case X =:= 0 of
        true ->
            Y;

        false ->
            _assert_subject = gleam@int:modulo(Y, X),
            {ok, Z} = case _assert_subject of
                {ok, _} -> _assert_subject;
                _assert_fail ->
                    erlang:error(#{gleam_error => let_assert,
                                message => <<"Assertion pattern match failed"/utf8>>,
                                value => _assert_fail,
                                module => <<"gleam_community/maths/arithmetics"/utf8>>,
                                function => <<"do_gcd"/utf8>>,
                                line => 93})
            end,
            do_gcd(Z, X)
    end.

-spec gcd(integer(), integer()) -> integer().
gcd(X, Y) ->
    Absx = gleam_community@maths@piecewise:int_absolute_value(X),
    Absy = gleam_community@maths@piecewise:int_absolute_value(Y),
    do_gcd(Absx, Absy).

-spec lcm(integer(), integer()) -> integer().
lcm(X, Y) ->
    Absx = gleam_community@maths@piecewise:int_absolute_value(X),
    Absy = gleam_community@maths@piecewise:int_absolute_value(Y),
    case do_gcd(Absx, Absy) of
        0 -> 0;
        Gleam@denominator -> Absx * Absy div Gleam@denominator
    end.

-spec find_divisors(integer()) -> list(integer()).
find_divisors(N) ->
    Nabs = gleam_community@maths@piecewise:float_absolute_value(
        gleam_community@maths@conversion:int_to_float(N)
    ),
    _assert_subject = gleam_community@maths@elementary:square_root(Nabs),
    {ok, Sqrt_result} = case _assert_subject of
        {ok, _} -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail,
                        module => <<"gleam_community/maths/arithmetics"/utf8>>,
                        function => <<"find_divisors"/utf8>>,
                        line => 176})
    end,
    Max = gleam_community@maths@conversion:float_to_int(Sqrt_result) + 1,
    _pipe = gleam@list:range(2, Max),
    _pipe@1 = gleam@list:fold(_pipe, [1, N], fun(Acc, I) -> case (case I of
                0 -> 0;
                Gleam@denominator -> N rem Gleam@denominator
            end) =:= 0 of
                true ->
                    [I, case I of
                            0 -> 0;
                            Gleam@denominator@1 -> N div Gleam@denominator@1
                        end | Acc];

                false ->
                    Acc
            end end),
    _pipe@2 = gleam@list:unique(_pipe@1),
    gleam@list:sort(_pipe@2, fun gleam@int:compare/2).

-spec divisors(integer()) -> list(integer()).
divisors(N) ->
    find_divisors(N).

-spec proper_divisors(integer()) -> list(integer()).
proper_divisors(N) ->
    Divisors = find_divisors(N),
    _pipe = Divisors,
    gleam@list:take(_pipe, gleam@list:length(Divisors) - 1).

-spec float_sum(list(float())) -> float().
float_sum(Arr) ->
    case Arr of
        [] ->
            +0.0;

        _ ->
            _pipe = Arr,
            gleam@list:fold(_pipe, +0.0, fun(Acc, A) -> A + Acc end)
    end.

-spec int_sum(list(integer())) -> integer().
int_sum(Arr) ->
    case Arr of
        [] ->
            0;

        _ ->
            _pipe = Arr,
            gleam@list:fold(_pipe, 0, fun(Acc, A) -> A + Acc end)
    end.

-spec float_product(list(float())) -> float().
float_product(Arr) ->
    case Arr of
        [] ->
            1.0;

        _ ->
            _pipe = Arr,
            gleam@list:fold(_pipe, 1.0, fun(Acc, A) -> A * Acc end)
    end.

-spec int_product(list(integer())) -> integer().
int_product(Arr) ->
    case Arr of
        [] ->
            1;

        _ ->
            _pipe = Arr,
            gleam@list:fold(_pipe, 1, fun(Acc, A) -> A * Acc end)
    end.

-spec float_cumulative_sum(list(float())) -> list(float()).
float_cumulative_sum(Arr) ->
    case Arr of
        [] ->
            [];

        _ ->
            _pipe = Arr,
            gleam@list:scan(_pipe, +0.0, fun(Acc, A) -> A + Acc end)
    end.

-spec int_cumulative_sum(list(integer())) -> list(integer()).
int_cumulative_sum(Arr) ->
    case Arr of
        [] ->
            [];

        _ ->
            _pipe = Arr,
            gleam@list:scan(_pipe, 0, fun(Acc, A) -> A + Acc end)
    end.

-spec float_cumumlative_product(list(float())) -> list(float()).
float_cumumlative_product(Arr) ->
    case Arr of
        [] ->
            [];

        _ ->
            _pipe = Arr,
            gleam@list:scan(_pipe, 1.0, fun(Acc, A) -> A * Acc end)
    end.

-spec int_cumulative_product(list(integer())) -> list(integer()).
int_cumulative_product(Arr) ->
    case Arr of
        [] ->
            [];

        _ ->
            _pipe = Arr,
            gleam@list:scan(_pipe, 1, fun(Acc, A) -> A * Acc end)
    end.

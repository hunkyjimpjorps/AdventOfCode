-module(gleam_community@maths@special).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function]).

-export([erf/1, gamma/1, beta/2, incomplete_gamma/2]).

-spec erf(float()) -> float().
erf(X) ->
    _assert_subject = [0.254829592,
        -0.284496736,
        1.421413741,
        -1.453152027,
        1.061405429],
    [A1, A2, A3, A4, A5] = case _assert_subject of
        [_, _, _, _, _] -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail,
                        module => <<"gleam_community/maths/special"/utf8>>,
                        function => <<"erf"/utf8>>,
                        line => 79})
    end,
    P = 0.3275911,
    Sign = gleam_community@maths@piecewise:float_sign(X),
    X@1 = gleam_community@maths@piecewise:float_absolute_value(X),
    T = case (1.0 + (P * X@1)) of
        0.0 -> 0.0;
        Gleam@denominator -> 1.0 / Gleam@denominator
    end,
    Y = 1.0 - ((((((((((A5 * T) + A4) * T) + A3) * T) + A2) * T) + A1) * T) * gleam_community@maths@elementary:exponential(
        (-1.0 * X@1) * X@1
    )),
    Sign * Y.

-spec gamma_lanczos(float()) -> float().
gamma_lanczos(X) ->
    case X < 0.5 of
        true ->
            case (gleam_community@maths@elementary:sin(
                gleam_community@maths@elementary:pi() * X
            )
            * gamma_lanczos(1.0 - X)) of
                0.0 -> 0.0;
                Gleam@denominator -> gleam_community@maths@elementary:pi() / Gleam@denominator
            end;

        false ->
            Z = X - 1.0,
            X@1 = gleam@list:index_fold(
                [0.99999999999980993,
                    676.5203681218851,
                    -1259.1392167224028,
                    771.32342877765313,
                    -176.61502916214059,
                    12.507343278686905,
                    -0.13857109526572012,
                    0.0000099843695780195716,
                    0.00000015056327351493116],
                +0.0,
                fun(Acc, V, Index) -> case Index > 0 of
                        true ->
                            Acc + (case (Z + gleam_community@maths@conversion:int_to_float(
                                Index
                            )) of
                                0.0 -> 0.0;
                                Gleam@denominator@1 -> V / Gleam@denominator@1
                            end);

                        false ->
                            V
                    end end
            ),
            T = (Z + 7.0) + 0.5,
            _assert_subject = gleam_community@maths@elementary:power(
                2.0 * gleam_community@maths@elementary:pi(),
                0.5
            ),
            {ok, V1} = case _assert_subject of
                {ok, _} -> _assert_subject;
                _assert_fail ->
                    erlang:error(#{gleam_error => let_assert,
                                message => <<"Assertion pattern match failed"/utf8>>,
                                value => _assert_fail,
                                module => <<"gleam_community/maths/special"/utf8>>,
                                function => <<"gamma_lanczos"/utf8>>,
                                line => 146})
            end,
            _assert_subject@1 = gleam_community@maths@elementary:power(
                T,
                Z + 0.5
            ),
            {ok, V2} = case _assert_subject@1 of
                {ok, _} -> _assert_subject@1;
                _assert_fail@1 ->
                    erlang:error(#{gleam_error => let_assert,
                                message => <<"Assertion pattern match failed"/utf8>>,
                                value => _assert_fail@1,
                                module => <<"gleam_community/maths/special"/utf8>>,
                                function => <<"gamma_lanczos"/utf8>>,
                                line => 147})
            end,
            ((V1 * V2) * gleam_community@maths@elementary:exponential(-1.0 * T))
            * X@1
    end.

-spec gamma(float()) -> float().
gamma(X) ->
    gamma_lanczos(X).

-spec beta(float(), float()) -> float().
beta(X, Y) ->
    case gamma(X + Y) of
        0.0 -> 0.0;
        Gleam@denominator -> (gamma(X) * gamma(Y)) / Gleam@denominator
    end.

-spec incomplete_gamma_sum(float(), float(), float(), float(), float()) -> float().
incomplete_gamma_sum(A, X, T, S, N) ->
    case T of
        +0.0 ->
            S;

        _ ->
            Ns = S + T,
            Nt = T * (case (A + N) of
                0.0 -> 0.0;
                Gleam@denominator -> X / Gleam@denominator
            end),
            incomplete_gamma_sum(A, X, Nt, Ns, N + 1.0)
    end.

-spec incomplete_gamma(float(), float()) -> {ok, float()} | {error, binary()}.
incomplete_gamma(A, X) ->
    case (A > +0.0) andalso (X >= +0.0) of
        true ->
            _assert_subject = gleam_community@maths@elementary:power(X, A),
            {ok, V} = case _assert_subject of
                {ok, _} -> _assert_subject;
                _assert_fail ->
                    erlang:error(#{gleam_error => let_assert,
                                message => <<"Assertion pattern match failed"/utf8>>,
                                value => _assert_fail,
                                module => <<"gleam_community/maths/special"/utf8>>,
                                function => <<"incomplete_gamma"/utf8>>,
                                line => 173})
            end,
            _pipe = (V * gleam_community@maths@elementary:exponential(-1.0 * X))
            * incomplete_gamma_sum(A, X, case A of
                    0.0 -> 0.0;
                    Gleam@denominator -> 1.0 / Gleam@denominator
                end, +0.0, 1.0),
            {ok, _pipe};

        false ->
            _pipe@1 = <<"Invlaid input argument: a <= 0 or x < 0. Valid input is a > 0 and x >= 0."/utf8>>,
            {error, _pipe@1}
    end.

-module(gleam_community@maths@elementary).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function]).

-export([acos/1, acosh/1, asin/1, asinh/1, atan/1, atan2/2, atanh/1, cos/1, cosh/1, sin/1, sinh/1, tan/1, tanh/1, exponential/1, natural_logarithm/1, logarithm_2/1, logarithm_10/1, logarithm/2, power/2, square_root/1, cube_root/1, nth_root/2, pi/0, tau/0, e/0]).

-spec acos(float()) -> {ok, float()} | {error, binary()}.
acos(X) ->
    case (X >= -1.0) andalso (X =< 1.0) of
        true ->
            _pipe = math:acos(X),
            {ok, _pipe};

        false ->
            _pipe@1 = <<"Invalid input argument: x >= -1 or x <= 1. Valid input is -1. <= x <= 1."/utf8>>,
            {error, _pipe@1}
    end.

-spec acosh(float()) -> {ok, float()} | {error, binary()}.
acosh(X) ->
    case X >= 1.0 of
        true ->
            _pipe = math:acosh(X),
            {ok, _pipe};

        false ->
            _pipe@1 = <<"Invalid input argument: x < 1. Valid input is x >= 1."/utf8>>,
            {error, _pipe@1}
    end.

-spec asin(float()) -> {ok, float()} | {error, binary()}.
asin(X) ->
    case (X >= -1.0) andalso (X =< 1.0) of
        true ->
            _pipe = math:asin(X),
            {ok, _pipe};

        false ->
            _pipe@1 = <<"Invalid input argument: x >= -1 or x <= 1. Valid input is -1. <= x <= 1."/utf8>>,
            {error, _pipe@1}
    end.

-spec asinh(float()) -> float().
asinh(X) ->
    math:asinh(X).

-spec atan(float()) -> float().
atan(X) ->
    math:atan(X).

-spec atan2(float(), float()) -> float().
atan2(Y, X) ->
    math:atan2(Y, X).

-spec atanh(float()) -> {ok, float()} | {error, binary()}.
atanh(X) ->
    case (X > -1.0) andalso (X < 1.0) of
        true ->
            _pipe = math:atanh(X),
            {ok, _pipe};

        false ->
            _pipe@1 = <<"Invalid input argument: x > -1 or x < 1. Valid input is -1. < x < 1."/utf8>>,
            {error, _pipe@1}
    end.

-spec cos(float()) -> float().
cos(X) ->
    math:cos(X).

-spec cosh(float()) -> float().
cosh(X) ->
    math:cosh(X).

-spec sin(float()) -> float().
sin(X) ->
    math:sin(X).

-spec sinh(float()) -> float().
sinh(X) ->
    math:sinh(X).

-spec tan(float()) -> float().
tan(X) ->
    math:tan(X).

-spec tanh(float()) -> float().
tanh(X) ->
    math:tanh(X).

-spec exponential(float()) -> float().
exponential(X) ->
    math:exp(X).

-spec natural_logarithm(float()) -> {ok, float()} | {error, binary()}.
natural_logarithm(X) ->
    case X > +0.0 of
        true ->
            _pipe = math:log(X),
            {ok, _pipe};

        false ->
            _pipe@1 = <<"Invalid input argument: x <= 0. Valid input is x > 0."/utf8>>,
            {error, _pipe@1}
    end.

-spec logarithm_2(float()) -> {ok, float()} | {error, binary()}.
logarithm_2(X) ->
    case X > +0.0 of
        true ->
            _pipe = math:log2(X),
            {ok, _pipe};

        false ->
            _pipe@1 = <<"Invalid input argument: x <= 0. Valid input is x > 0."/utf8>>,
            {error, _pipe@1}
    end.

-spec logarithm_10(float()) -> {ok, float()} | {error, binary()}.
logarithm_10(X) ->
    case X > +0.0 of
        true ->
            _pipe = math:log10(X),
            {ok, _pipe};

        false ->
            _pipe@1 = <<"Invalid input argument: x <= 0. Valid input is x > 0."/utf8>>,
            {error, _pipe@1}
    end.

-spec logarithm(float(), gleam@option:option(float())) -> {ok, float()} |
    {error, binary()}.
logarithm(X, Base) ->
    case X > +0.0 of
        true ->
            case Base of
                {some, A} ->
                    case (A > +0.0) andalso (A /= 1.0) of
                        true ->
                            _assert_subject = logarithm_10(X),
                            {ok, Numerator} = case _assert_subject of
                                {ok, _} -> _assert_subject;
                                _assert_fail ->
                                    erlang:error(#{gleam_error => let_assert,
                                                message => <<"Assertion pattern match failed"/utf8>>,
                                                value => _assert_fail,
                                                module => <<"gleam_community/maths/elementary"/utf8>>,
                                                function => <<"logarithm"/utf8>>,
                                                line => 820})
                            end,
                            _assert_subject@1 = logarithm_10(A),
                            {ok, Denominator} = case _assert_subject@1 of
                                {ok, _} -> _assert_subject@1;
                                _assert_fail@1 ->
                                    erlang:error(#{gleam_error => let_assert,
                                                message => <<"Assertion pattern match failed"/utf8>>,
                                                value => _assert_fail@1,
                                                module => <<"gleam_community/maths/elementary"/utf8>>,
                                                function => <<"logarithm"/utf8>>,
                                                line => 821})
                            end,
                            _pipe = case Denominator of
                                +0.0 -> +0.0;
                                -0.0 -> -0.0;
                                Gleam@denominator -> Numerator / Gleam@denominator
                            end,
                            {ok, _pipe};

                        false ->
                            _pipe@1 = <<"Invalid input argument: base <= 0 or base == 1. Valid input is base > 0 and base != 1."/utf8>>,
                            {error, _pipe@1}
                    end;

                _ ->
                    _pipe@2 = <<"Invalid input argument: base <= 0 or base == 1. Valid input is base > 0 and base != 1."/utf8>>,
                    {error, _pipe@2}
            end;

        _ ->
            _pipe@3 = <<"Invalid input argument: x <= 0. Valid input is x > 0."/utf8>>,
            {error, _pipe@3}
    end.

-spec power(float(), float()) -> {ok, float()} | {error, binary()}.
power(X, Y) ->
    Fractional = (math:ceil(Y) - Y) > +0.0,
    case ((X < +0.0) andalso Fractional) orelse ((X =:= +0.0) andalso (Y < +0.0)) of
        true ->
            _pipe = <<"Invalid input argument: x < 0 and y is fractional or x = 0 and y < 0."/utf8>>,
            {error, _pipe};

        false ->
            _pipe@1 = math:pow(X, Y),
            {ok, _pipe@1}
    end.

-spec square_root(float()) -> {ok, float()} | {error, binary()}.
square_root(X) ->
    case X < +0.0 of
        true ->
            _pipe = <<"Invalid input argument: x < 0."/utf8>>,
            {error, _pipe};

        false ->
            _assert_subject = power(X, 1.0 / 2.0),
            {ok, Result} = case _assert_subject of
                {ok, _} -> _assert_subject;
                _assert_fail ->
                    erlang:error(#{gleam_error => let_assert,
                                message => <<"Assertion pattern match failed"/utf8>>,
                                value => _assert_fail,
                                module => <<"gleam_community/maths/elementary"/utf8>>,
                                function => <<"square_root"/utf8>>,
                                line => 1066})
            end,
            _pipe@1 = Result,
            {ok, _pipe@1}
    end.

-spec cube_root(float()) -> {ok, float()} | {error, binary()}.
cube_root(X) ->
    case X < +0.0 of
        true ->
            _pipe = <<"Invalid input argument: x < 0."/utf8>>,
            {error, _pipe};

        false ->
            _assert_subject = power(X, 1.0 / 3.0),
            {ok, Result} = case _assert_subject of
                {ok, _} -> _assert_subject;
                _assert_fail ->
                    erlang:error(#{gleam_error => let_assert,
                                message => <<"Assertion pattern match failed"/utf8>>,
                                value => _assert_fail,
                                module => <<"gleam_community/maths/elementary"/utf8>>,
                                function => <<"cube_root"/utf8>>,
                                line => 1118})
            end,
            _pipe@1 = Result,
            {ok, _pipe@1}
    end.

-spec nth_root(float(), integer()) -> {ok, float()} | {error, binary()}.
nth_root(X, N) ->
    case X < +0.0 of
        true ->
            _pipe = <<"Invalid input argument: x < 0. Valid input is x > 0"/utf8>>,
            {error, _pipe};

        false ->
            case N >= 1 of
                true ->
                    _assert_subject = power(X, case gleam@int:to_float(N) of
                            +0.0 -> +0.0;
                            -0.0 -> -0.0;
                            Gleam@denominator -> 1.0 / Gleam@denominator
                        end),
                    {ok, Result} = case _assert_subject of
                        {ok, _} -> _assert_subject;
                        _assert_fail ->
                            erlang:error(#{gleam_error => let_assert,
                                        message => <<"Assertion pattern match failed"/utf8>>,
                                        value => _assert_fail,
                                        module => <<"gleam_community/maths/elementary"/utf8>>,
                                        function => <<"nth_root"/utf8>>,
                                        line => 1175})
                    end,
                    _pipe@1 = Result,
                    {ok, _pipe@1};

                false ->
                    _pipe@2 = <<"Invalid input argument: n < 1. Valid input is n >= 2."/utf8>>,
                    {error, _pipe@2}
            end
    end.

-spec pi() -> float().
pi() ->
    math:pi().

-spec tau() -> float().
tau() ->
    2.0 * pi().

-spec e() -> float().
e() ->
    exponential(1.0).

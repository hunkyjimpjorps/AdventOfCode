-module(gleam_community@maths@piecewise).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function]).

-export([float_absolute_value/1, int_absolute_value/1, float_absolute_difference/2, int_absolute_difference/2, float_sign/1, round/3, ceiling/2, floor/2, truncate/2, int_sign/1, float_flip_sign/1, float_copy_sign/2, int_flip_sign/1, int_copy_sign/2, minimum/3, maximum/3, minmax/3, list_minimum/2, list_maximum/2, arg_minimum/2, arg_maximum/2, extrema/2]).
-export_type([rounding_mode/0]).

-type rounding_mode() :: round_nearest |
    round_ties_away |
    round_ties_up |
    round_to_zero |
    round_down |
    round_up.

-spec truncate_float(float()) -> float().
truncate_float(X) ->
    erlang:trunc(X).

-spec round_to_zero(float(), float()) -> float().
round_to_zero(P, X) ->
    case P of
        0.0 -> 0.0;
        Gleam@denominator -> truncate_float(X * P) / Gleam@denominator
    end.

-spec round_down(float(), float()) -> float().
round_down(P, X) ->
    case P of
        0.0 -> 0.0;
        Gleam@denominator -> math:floor(X * P) / Gleam@denominator
    end.

-spec round_up(float(), float()) -> float().
round_up(P, X) ->
    case P of
        0.0 -> 0.0;
        Gleam@denominator -> math:ceil(X * P) / Gleam@denominator
    end.

-spec float_absolute_value(float()) -> float().
float_absolute_value(X) ->
    case X > +0.0 of
        true ->
            X;

        false ->
            -1.0 * X
    end.

-spec int_absolute_value(integer()) -> integer().
int_absolute_value(X) ->
    case X > 0 of
        true ->
            X;

        false ->
            -1 * X
    end.

-spec float_absolute_difference(float(), float()) -> float().
float_absolute_difference(A, B) ->
    _pipe = A - B,
    float_absolute_value(_pipe).

-spec int_absolute_difference(integer(), integer()) -> integer().
int_absolute_difference(A, B) ->
    _pipe = A - B,
    int_absolute_value(_pipe).

-spec do_float_sign(float()) -> float().
do_float_sign(X) ->
    case X < +0.0 of
        true ->
            -1.0;

        false ->
            case X =:= +0.0 of
                true ->
                    +0.0;

                false ->
                    1.0
            end
    end.

-spec float_sign(float()) -> float().
float_sign(X) ->
    do_float_sign(X).

-spec round_to_nearest(float(), float()) -> float().
round_to_nearest(P, X) ->
    Xabs = float_absolute_value(X) * P,
    Xabs_truncated = truncate_float(Xabs),
    Remainder = Xabs - Xabs_truncated,
    case Remainder of
        _ when Remainder > 0.5 ->
            case P of
                0.0 -> 0.0;
                Gleam@denominator -> (float_sign(X) * truncate_float(Xabs + 1.0))
                / Gleam@denominator
            end;

        _ when Remainder =:= 0.5 ->
            _assert_subject = gleam@int:modulo(
                gleam_community@maths@conversion:float_to_int(Xabs),
                2
            ),
            {ok, Is_even} = case _assert_subject of
                {ok, _} -> _assert_subject;
                _assert_fail ->
                    erlang:error(#{gleam_error => let_assert,
                                message => <<"Assertion pattern match failed"/utf8>>,
                                value => _assert_fail,
                                module => <<"gleam_community/maths/piecewise"/utf8>>,
                                function => <<"round_to_nearest"/utf8>>,
                                line => 423})
            end,
            case Is_even =:= 0 of
                true ->
                    case P of
                        0.0 -> 0.0;
                        Gleam@denominator@1 -> (float_sign(X) * Xabs_truncated)
                        / Gleam@denominator@1
                    end;

                false ->
                    case P of
                        0.0 -> 0.0;
                        Gleam@denominator@2 -> (float_sign(X) * truncate_float(
                            Xabs + 1.0
                        ))
                        / Gleam@denominator@2
                    end
            end;

        _ ->
            case P of
                0.0 -> 0.0;
                Gleam@denominator@3 -> (float_sign(X) * Xabs_truncated) / Gleam@denominator@3
            end
    end.

-spec round_ties_away(float(), float()) -> float().
round_ties_away(P, X) ->
    Xabs = float_absolute_value(X) * P,
    Remainder = Xabs - truncate_float(Xabs),
    case Remainder of
        _ when Remainder >= 0.5 ->
            case P of
                0.0 -> 0.0;
                Gleam@denominator -> (float_sign(X) * truncate_float(Xabs + 1.0))
                / Gleam@denominator
            end;

        _ ->
            case P of
                0.0 -> 0.0;
                Gleam@denominator@1 -> (float_sign(X) * truncate_float(Xabs)) / Gleam@denominator@1
            end
    end.

-spec round_ties_up(float(), float()) -> float().
round_ties_up(P, X) ->
    Xabs = float_absolute_value(X) * P,
    Xabs_truncated = truncate_float(Xabs),
    Remainder = Xabs - Xabs_truncated,
    case Remainder of
        _ when (Remainder >= 0.5) andalso (X >= +0.0) ->
            case P of
                0.0 -> 0.0;
                Gleam@denominator -> (float_sign(X) * truncate_float(Xabs + 1.0))
                / Gleam@denominator
            end;

        _ ->
            case P of
                0.0 -> 0.0;
                Gleam@denominator@1 -> (float_sign(X) * Xabs_truncated) / Gleam@denominator@1
            end
    end.

-spec do_round(float(), float(), gleam@option:option(rounding_mode())) -> {ok,
        float()} |
    {error, binary()}.
do_round(P, X, Mode) ->
    case Mode of
        {some, round_nearest} ->
            _pipe = round_to_nearest(P, X),
            {ok, _pipe};

        {some, round_ties_away} ->
            _pipe@1 = round_ties_away(P, X),
            {ok, _pipe@1};

        {some, round_ties_up} ->
            _pipe@2 = round_ties_up(P, X),
            {ok, _pipe@2};

        {some, round_to_zero} ->
            _pipe@3 = round_to_zero(P, X),
            {ok, _pipe@3};

        {some, round_down} ->
            _pipe@4 = round_down(P, X),
            {ok, _pipe@4};

        {some, round_up} ->
            _pipe@5 = round_up(P, X),
            {ok, _pipe@5};

        none ->
            _pipe@6 = round_to_nearest(P, X),
            {ok, _pipe@6}
    end.

-spec round(
    float(),
    gleam@option:option(integer()),
    gleam@option:option(rounding_mode())
) -> {ok, float()} | {error, binary()}.
round(X, Digits, Mode) ->
    case Digits of
        {some, A} ->
            _assert_subject = gleam_community@maths@elementary:power(
                10.0,
                gleam_community@maths@conversion:int_to_float(A)
            ),
            {ok, P} = case _assert_subject of
                {ok, _} -> _assert_subject;
                _assert_fail ->
                    erlang:error(#{gleam_error => let_assert,
                                message => <<"Assertion pattern match failed"/utf8>>,
                                value => _assert_fail,
                                module => <<"gleam_community/maths/piecewise"/utf8>>,
                                function => <<"round"/utf8>>,
                                line => 366})
            end,
            do_round(P, X, Mode);

        none ->
            do_round(1.0, X, Mode)
    end.

-spec ceiling(float(), gleam@option:option(integer())) -> {ok, float()} |
    {error, binary()}.
ceiling(X, Digits) ->
    round(X, Digits, {some, round_up}).

-spec floor(float(), gleam@option:option(integer())) -> {ok, float()} |
    {error, binary()}.
floor(X, Digits) ->
    round(X, Digits, {some, round_down}).

-spec truncate(float(), gleam@option:option(integer())) -> {ok, float()} |
    {error, binary()}.
truncate(X, Digits) ->
    round(X, Digits, {some, round_to_zero}).

-spec do_int_sign(integer()) -> integer().
do_int_sign(X) ->
    case X < 0 of
        true ->
            -1;

        false ->
            case X =:= 0 of
                true ->
                    0;

                false ->
                    1
            end
    end.

-spec int_sign(integer()) -> integer().
int_sign(X) ->
    do_int_sign(X).

-spec float_flip_sign(float()) -> float().
float_flip_sign(X) ->
    -1.0 * X.

-spec float_copy_sign(float(), float()) -> float().
float_copy_sign(X, Y) ->
    case float_sign(X) =:= float_sign(Y) of
        true ->
            X;

        false ->
            float_flip_sign(X)
    end.

-spec int_flip_sign(integer()) -> integer().
int_flip_sign(X) ->
    -1 * X.

-spec int_copy_sign(integer(), integer()) -> integer().
int_copy_sign(X, Y) ->
    case int_sign(X) =:= int_sign(Y) of
        true ->
            X;

        false ->
            int_flip_sign(X)
    end.

-spec minimum(FQL, FQL, fun((FQL, FQL) -> gleam@order:order())) -> FQL.
minimum(X, Y, Compare) ->
    case Compare(X, Y) of
        lt ->
            X;

        eq ->
            X;

        gt ->
            Y
    end.

-spec maximum(FQM, FQM, fun((FQM, FQM) -> gleam@order:order())) -> FQM.
maximum(X, Y, Compare) ->
    case Compare(X, Y) of
        lt ->
            Y;

        eq ->
            Y;

        gt ->
            X
    end.

-spec minmax(FQN, FQN, fun((FQN, FQN) -> gleam@order:order())) -> {FQN, FQN}.
minmax(X, Y, Compare) ->
    {minimum(X, Y, Compare), maximum(X, Y, Compare)}.

-spec list_minimum(list(FQO), fun((FQO, FQO) -> gleam@order:order())) -> {ok,
        FQO} |
    {error, binary()}.
list_minimum(Arr, Compare) ->
    case Arr of
        [] ->
            _pipe = <<"Invalid input argument: The list is empty."/utf8>>,
            {error, _pipe};

        _ ->
            _assert_subject = gleam@list:at(Arr, 0),
            {ok, Val0} = case _assert_subject of
                {ok, _} -> _assert_subject;
                _assert_fail ->
                    erlang:error(#{gleam_error => let_assert,
                                message => <<"Assertion pattern match failed"/utf8>>,
                                value => _assert_fail,
                                module => <<"gleam_community/maths/piecewise"/utf8>>,
                                function => <<"list_minimum"/utf8>>,
                                line => 945})
            end,
            _pipe@1 = Arr,
            _pipe@2 = gleam@list:fold(
                _pipe@1,
                Val0,
                fun(Acc, Element) -> case Compare(Element, Acc) of
                        lt ->
                            Element;

                        _ ->
                            Acc
                    end end
            ),
            {ok, _pipe@2}
    end.

-spec list_maximum(list(FQS), fun((FQS, FQS) -> gleam@order:order())) -> {ok,
        FQS} |
    {error, binary()}.
list_maximum(Arr, Compare) ->
    case Arr of
        [] ->
            _pipe = <<"Invalid input argument: The list is empty."/utf8>>,
            {error, _pipe};

        _ ->
            _assert_subject = gleam@list:at(Arr, 0),
            {ok, Val0} = case _assert_subject of
                {ok, _} -> _assert_subject;
                _assert_fail ->
                    erlang:error(#{gleam_error => let_assert,
                                message => <<"Assertion pattern match failed"/utf8>>,
                                value => _assert_fail,
                                module => <<"gleam_community/maths/piecewise"/utf8>>,
                                function => <<"list_maximum"/utf8>>,
                                line => 1004})
            end,
            _pipe@1 = Arr,
            _pipe@2 = gleam@list:fold(
                _pipe@1,
                Val0,
                fun(Acc, Element) -> case Compare(Acc, Element) of
                        lt ->
                            Element;

                        _ ->
                            Acc
                    end end
            ),
            {ok, _pipe@2}
    end.

-spec arg_minimum(list(FQW), fun((FQW, FQW) -> gleam@order:order())) -> {ok,
        list(integer())} |
    {error, binary()}.
arg_minimum(Arr, Compare) ->
    case Arr of
        [] ->
            _pipe = <<"Invalid input argument: The list is empty."/utf8>>,
            {error, _pipe};

        _ ->
            _assert_subject = begin
                _pipe@1 = Arr,
                list_minimum(_pipe@1, Compare)
            end,
            {ok, Min} = case _assert_subject of
                {ok, _} -> _assert_subject;
                _assert_fail ->
                    erlang:error(#{gleam_error => let_assert,
                                message => <<"Assertion pattern match failed"/utf8>>,
                                value => _assert_fail,
                                module => <<"gleam_community/maths/piecewise"/utf8>>,
                                function => <<"arg_minimum"/utf8>>,
                                line => 1069})
            end,
            _pipe@2 = Arr,
            _pipe@3 = gleam@list:index_map(
                _pipe@2,
                fun(Index, Element) -> case Compare(Element, Min) of
                        eq ->
                            Index;

                        _ ->
                            -1
                    end end
            ),
            _pipe@4 = gleam@list:filter(_pipe@3, fun(Index@1) -> case Index@1 of
                        -1 ->
                            false;

                        _ ->
                            true
                    end end),
            {ok, _pipe@4}
    end.

-spec arg_maximum(list(FRB), fun((FRB, FRB) -> gleam@order:order())) -> {ok,
        list(integer())} |
    {error, binary()}.
arg_maximum(Arr, Compare) ->
    case Arr of
        [] ->
            _pipe = <<"Invalid input argument: The list is empty."/utf8>>,
            {error, _pipe};

        _ ->
            _assert_subject = begin
                _pipe@1 = Arr,
                list_maximum(_pipe@1, Compare)
            end,
            {ok, Max} = case _assert_subject of
                {ok, _} -> _assert_subject;
                _assert_fail ->
                    erlang:error(#{gleam_error => let_assert,
                                message => <<"Assertion pattern match failed"/utf8>>,
                                value => _assert_fail,
                                module => <<"gleam_community/maths/piecewise"/utf8>>,
                                function => <<"arg_maximum"/utf8>>,
                                line => 1139})
            end,
            _pipe@2 = Arr,
            _pipe@3 = gleam@list:index_map(
                _pipe@2,
                fun(Index, Element) -> case Compare(Element, Max) of
                        eq ->
                            Index;

                        _ ->
                            -1
                    end end
            ),
            _pipe@4 = gleam@list:filter(_pipe@3, fun(Index@1) -> case Index@1 of
                        -1 ->
                            false;

                        _ ->
                            true
                    end end),
            {ok, _pipe@4}
    end.

-spec extrema(list(FRG), fun((FRG, FRG) -> gleam@order:order())) -> {ok,
        {FRG, FRG}} |
    {error, binary()}.
extrema(Arr, Compare) ->
    case Arr of
        [] ->
            _pipe = <<"Invalid input argument: The list is empty."/utf8>>,
            {error, _pipe};

        _ ->
            _assert_subject = gleam@list:at(Arr, 0),
            {ok, Val_max} = case _assert_subject of
                {ok, _} -> _assert_subject;
                _assert_fail ->
                    erlang:error(#{gleam_error => let_assert,
                                message => <<"Assertion pattern match failed"/utf8>>,
                                value => _assert_fail,
                                module => <<"gleam_community/maths/piecewise"/utf8>>,
                                function => <<"extrema"/utf8>>,
                                line => 1209})
            end,
            _assert_subject@1 = gleam@list:at(Arr, 0),
            {ok, Val_min} = case _assert_subject@1 of
                {ok, _} -> _assert_subject@1;
                _assert_fail@1 ->
                    erlang:error(#{gleam_error => let_assert,
                                message => <<"Assertion pattern match failed"/utf8>>,
                                value => _assert_fail@1,
                                module => <<"gleam_community/maths/piecewise"/utf8>>,
                                function => <<"extrema"/utf8>>,
                                line => 1210})
            end,
            _pipe@1 = Arr,
            _pipe@2 = gleam@list:fold(
                _pipe@1,
                {Val_min, Val_max},
                fun(Acc, Element) ->
                    First = gleam@pair:first(Acc),
                    Second = gleam@pair:second(Acc),
                    case {Compare(Element, First), Compare(Second, Element)} of
                        {lt, lt} ->
                            {Element, Element};

                        {lt, _} ->
                            {Element, Second};

                        {_, lt} ->
                            {First, Element};

                        {_, _} ->
                            {First, Second}
                    end
                end
            ),
            {ok, _pipe@2}
    end.

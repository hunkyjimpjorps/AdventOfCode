-module(gleam_community@maths@metrics).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch]).

-export([norm/2, minkowski_distance/3, manhatten_distance/2, euclidean_distance/2, mean/1, median/1, variance/2, standard_deviation/2]).

-spec norm(list(float()), float()) -> float().
norm(Arr, P) ->
    case Arr of
        [] ->
            +0.0;

        _ ->
            Agg = begin
                _pipe = Arr,
                gleam@list:fold(
                    _pipe,
                    +0.0,
                    fun(Acc, A) ->
                        _assert_subject = gleam_community@maths@elementary:power(
                            gleam_community@maths@piecewise:float_absolute_value(
                                A
                            ),
                            P
                        ),
                        {ok, Result} = case _assert_subject of
                            {ok, _} -> _assert_subject;
                            _assert_fail ->
                                erlang:error(#{gleam_error => let_assert,
                                            message => <<"Assertion pattern match failed"/utf8>>,
                                            value => _assert_fail,
                                            module => <<"gleam_community/maths/metrics"/utf8>>,
                                            function => <<"norm"/utf8>>,
                                            line => 101})
                        end,
                        Result + Acc
                    end
                )
            end,
            _assert_subject@1 = gleam_community@maths@elementary:power(
                Agg,
                case P of
                    +0.0 -> +0.0;
                    -0.0 -> -0.0;
                    Gleam@denominator -> 1.0 / Gleam@denominator
                end
            ),
            {ok, Result@1} = case _assert_subject@1 of
                {ok, _} -> _assert_subject@1;
                _assert_fail@1 ->
                    erlang:error(#{gleam_error => let_assert,
                                message => <<"Assertion pattern match failed"/utf8>>,
                                value => _assert_fail@1,
                                module => <<"gleam_community/maths/metrics"/utf8>>,
                                function => <<"norm"/utf8>>,
                                line => 106})
            end,
            Result@1
    end.

-spec minkowski_distance(list(float()), list(float()), float()) -> {ok, float()} |
    {error, binary()}.
minkowski_distance(Xarr, Yarr, P) ->
    Xlen = gleam@list:length(Xarr),
    Ylen = gleam@list:length(Yarr),
    case Xlen =:= Ylen of
        false ->
            _pipe = <<"Invalid input argument: length(xarr) != length(yarr). Valid input is when length(xarr) == length(yarr)."/utf8>>,
            {error, _pipe};

        true ->
            case P < 1.0 of
                true ->
                    _pipe@1 = <<"Invalid input argument: p < 1. Valid input is p >= 1."/utf8>>,
                    {error, _pipe@1};

                false ->
                    _pipe@2 = gleam@list:zip(Xarr, Yarr),
                    _pipe@3 = gleam@list:map(
                        _pipe@2,
                        fun(Tuple) ->
                            gleam@pair:first(Tuple) - gleam@pair:second(Tuple)
                        end
                    ),
                    _pipe@4 = norm(_pipe@3, P),
                    {ok, _pipe@4}
            end
    end.

-spec manhatten_distance(list(float()), list(float())) -> {ok, float()} |
    {error, binary()}.
manhatten_distance(Xarr, Yarr) ->
    minkowski_distance(Xarr, Yarr, 1.0).

-spec euclidean_distance(list(float()), list(float())) -> {ok, float()} |
    {error, binary()}.
euclidean_distance(Xarr, Yarr) ->
    minkowski_distance(Xarr, Yarr, 2.0).

-spec mean(list(float())) -> {ok, float()} | {error, binary()}.
mean(Arr) ->
    case Arr of
        [] ->
            _pipe = <<"Invalid input argument: The list is empty."/utf8>>,
            {error, _pipe};

        _ ->
            _pipe@1 = Arr,
            _pipe@2 = gleam_community@maths@arithmetics:float_sum(_pipe@1),
            _pipe@3 = (fun(A) ->
                case gleam_community@maths@conversion:int_to_float(
                    gleam@list:length(Arr)
                ) of
                    +0.0 -> +0.0;
                    -0.0 -> -0.0;
                    Gleam@denominator -> A / Gleam@denominator
                end
            end)(_pipe@2),
            {ok, _pipe@3}
    end.

-spec median(list(float())) -> {ok, float()} | {error, binary()}.
median(Arr) ->
    case Arr of
        [] ->
            _pipe = <<"Invalid input argument: The list is empty."/utf8>>,
            {error, _pipe};

        _ ->
            Count = gleam@list:length(Arr),
            Mid = gleam@list:length(Arr) div 2,
            Sorted = gleam@list:sort(Arr, fun gleam@float:compare/2),
            case gleam_community@maths@predicates:is_odd(Count) of
                true ->
                    _assert_subject = gleam@list:at(Sorted, Mid),
                    {ok, Val0} = case _assert_subject of
                        {ok, _} -> _assert_subject;
                        _assert_fail ->
                            erlang:error(#{gleam_error => let_assert,
                                        message => <<"Assertion pattern match failed"/utf8>>,
                                        value => _assert_fail,
                                        module => <<"gleam_community/maths/metrics"/utf8>>,
                                        function => <<"median"/utf8>>,
                                        line => 402})
                    end,
                    _pipe@1 = Val0,
                    {ok, _pipe@1};

                false ->
                    _assert_subject@1 = gleam@list:at(Sorted, Mid - 1),
                    {ok, Val0@1} = case _assert_subject@1 of
                        {ok, _} -> _assert_subject@1;
                        _assert_fail@1 ->
                            erlang:error(#{gleam_error => let_assert,
                                        message => <<"Assertion pattern match failed"/utf8>>,
                                        value => _assert_fail@1,
                                        module => <<"gleam_community/maths/metrics"/utf8>>,
                                        function => <<"median"/utf8>>,
                                        line => 409})
                    end,
                    _assert_subject@2 = gleam@list:at(Sorted, Mid),
                    {ok, Val1} = case _assert_subject@2 of
                        {ok, _} -> _assert_subject@2;
                        _assert_fail@2 ->
                            erlang:error(#{gleam_error => let_assert,
                                        message => <<"Assertion pattern match failed"/utf8>>,
                                        value => _assert_fail@2,
                                        module => <<"gleam_community/maths/metrics"/utf8>>,
                                        function => <<"median"/utf8>>,
                                        line => 410})
                    end,
                    _pipe@2 = [Val0@1, Val1],
                    mean(_pipe@2)
            end
    end.

-spec variance(list(float()), integer()) -> {ok, float()} | {error, binary()}.
variance(Arr, Ddof) ->
    case Arr of
        [] ->
            _pipe = <<"Invalid input argument: The list is empty."/utf8>>,
            {error, _pipe};

        _ ->
            case Ddof < 0 of
                true ->
                    _pipe@1 = <<"Invalid input argument: ddof < 0. Valid input is ddof >= 0."/utf8>>,
                    {error, _pipe@1};

                false ->
                    _assert_subject = mean(Arr),
                    {ok, Mean} = case _assert_subject of
                        {ok, _} -> _assert_subject;
                        _assert_fail ->
                            erlang:error(#{gleam_error => let_assert,
                                        message => <<"Assertion pattern match failed"/utf8>>,
                                        value => _assert_fail,
                                        module => <<"gleam_community/maths/metrics"/utf8>>,
                                        function => <<"variance"/utf8>>,
                                        line => 475})
                    end,
                    _pipe@2 = Arr,
                    _pipe@3 = gleam@list:map(
                        _pipe@2,
                        fun(A) ->
                            _assert_subject@1 = gleam_community@maths@elementary:power(
                                A - Mean,
                                2.0
                            ),
                            {ok, Result} = case _assert_subject@1 of
                                {ok, _} -> _assert_subject@1;
                                _assert_fail@1 ->
                                    erlang:error(#{gleam_error => let_assert,
                                                message => <<"Assertion pattern match failed"/utf8>>,
                                                value => _assert_fail@1,
                                                module => <<"gleam_community/maths/metrics"/utf8>>,
                                                function => <<"variance"/utf8>>,
                                                line => 478})
                            end,
                            Result
                        end
                    ),
                    _pipe@4 = gleam_community@maths@arithmetics:float_sum(
                        _pipe@3
                    ),
                    _pipe@5 = (fun(A@1) ->
                        case (gleam_community@maths@conversion:int_to_float(
                            gleam@list:length(Arr)
                        )
                        - gleam_community@maths@conversion:int_to_float(Ddof)) of
                            +0.0 -> +0.0;
                            -0.0 -> -0.0;
                            Gleam@denominator -> A@1 / Gleam@denominator
                        end
                    end)(_pipe@4),
                    {ok, _pipe@5}
            end
    end.

-spec standard_deviation(list(float()), integer()) -> {ok, float()} |
    {error, binary()}.
standard_deviation(Arr, Ddof) ->
    case Arr of
        [] ->
            _pipe = <<"Invalid input argument: The list is empty."/utf8>>,
            {error, _pipe};

        _ ->
            case Ddof < 0 of
                true ->
                    _pipe@1 = <<"Invalid input argument: ddof < 0. Valid input is ddof >= 0."/utf8>>,
                    {error, _pipe@1};

                false ->
                    _assert_subject = variance(Arr, Ddof),
                    {ok, Variance} = case _assert_subject of
                        {ok, _} -> _assert_subject;
                        _assert_fail ->
                            erlang:error(#{gleam_error => let_assert,
                                        message => <<"Assertion pattern match failed"/utf8>>,
                                        value => _assert_fail,
                                        module => <<"gleam_community/maths/metrics"/utf8>>,
                                        function => <<"standard_deviation"/utf8>>,
                                        line => 551})
                    end,
                    _assert_subject@1 = gleam_community@maths@elementary:square_root(
                        Variance
                    ),
                    {ok, Stdev} = case _assert_subject@1 of
                        {ok, _} -> _assert_subject@1;
                        _assert_fail@1 ->
                            erlang:error(#{gleam_error => let_assert,
                                        message => <<"Assertion pattern match failed"/utf8>>,
                                        value => _assert_fail@1,
                                        module => <<"gleam_community/maths/metrics"/utf8>>,
                                        function => <<"standard_deviation"/utf8>>,
                                        line => 554})
                    end,
                    _pipe@2 = Stdev,
                    {ok, _pipe@2}
            end
    end.

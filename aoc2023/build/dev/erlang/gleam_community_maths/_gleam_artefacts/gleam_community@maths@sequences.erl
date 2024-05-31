-module(gleam_community@maths@sequences).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch]).

-export([arange/3, linear_space/4, logarithmic_space/5, geometric_space/4]).

-spec arange(float(), float(), float()) -> list(float()).
arange(Start, Stop, Step) ->
    case ((Start >= Stop) andalso (Step > +0.0)) orelse ((Start =< Stop) andalso (Step
    < +0.0)) of
        true ->
            [];

        false ->
            Direction = case Start =< Stop of
                true ->
                    1.0;

                false ->
                    -1.0
            end,
            Step_abs = gleam_community@maths@piecewise:float_absolute_value(
                Step
            ),
            Num = case Step_abs of
                +0.0 -> +0.0;
                -0.0 -> -0.0;
                Gleam@denominator -> gleam_community@maths@piecewise:float_absolute_value(
                    Start - Stop
                )
                / Gleam@denominator
            end,
            _pipe = gleam@list:range(
                0,
                gleam_community@maths@conversion:float_to_int(Num) - 1
            ),
            gleam@list:map(
                _pipe,
                fun(I) ->
                    Start + ((gleam_community@maths@conversion:int_to_float(I) * Step_abs)
                    * Direction)
                end
            )
    end.

-spec linear_space(float(), float(), integer(), boolean()) -> {ok,
        list(float())} |
    {error, binary()}.
linear_space(Start, Stop, Num, Endpoint) ->
    Direction = case Start =< Stop of
        true ->
            1.0;

        false ->
            -1.0
    end,
    case Num > 0 of
        true ->
            case Endpoint of
                true ->
                    Increment = case gleam_community@maths@conversion:int_to_float(
                        Num - 1
                    ) of
                        +0.0 -> +0.0;
                        -0.0 -> -0.0;
                        Gleam@denominator -> gleam_community@maths@piecewise:float_absolute_value(
                            Start - Stop
                        )
                        / Gleam@denominator
                    end,
                    _pipe = gleam@list:range(0, Num - 1),
                    _pipe@1 = gleam@list:map(
                        _pipe,
                        fun(I) ->
                            Start + ((gleam_community@maths@conversion:int_to_float(
                                I
                            )
                            * Increment)
                            * Direction)
                        end
                    ),
                    {ok, _pipe@1};

                false ->
                    Increment@1 = case gleam_community@maths@conversion:int_to_float(
                        Num
                    ) of
                        +0.0 -> +0.0;
                        -0.0 -> -0.0;
                        Gleam@denominator@1 -> gleam_community@maths@piecewise:float_absolute_value(
                            Start - Stop
                        )
                        / Gleam@denominator@1
                    end,
                    _pipe@2 = gleam@list:range(0, Num - 1),
                    _pipe@3 = gleam@list:map(
                        _pipe@2,
                        fun(I@1) ->
                            Start + ((gleam_community@maths@conversion:int_to_float(
                                I@1
                            )
                            * Increment@1)
                            * Direction)
                        end
                    ),
                    {ok, _pipe@3}
            end;

        false ->
            _pipe@4 = <<"Invalid input: num < 0. Valid input is num > 0."/utf8>>,
            {error, _pipe@4}
    end.

-spec logarithmic_space(float(), float(), integer(), boolean(), float()) -> {ok,
        list(float())} |
    {error, binary()}.
logarithmic_space(Start, Stop, Num, Endpoint, Base) ->
    case Num > 0 of
        true ->
            _assert_subject = linear_space(Start, Stop, Num, Endpoint),
            {ok, Linspace} = case _assert_subject of
                {ok, _} -> _assert_subject;
                _assert_fail ->
                    erlang:error(#{gleam_error => let_assert,
                                message => <<"Assertion pattern match failed"/utf8>>,
                                value => _assert_fail,
                                module => <<"gleam_community/maths/sequences"/utf8>>,
                                function => <<"logarithmic_space"/utf8>>,
                                line => 221})
            end,
            _pipe = Linspace,
            _pipe@1 = gleam@list:map(
                _pipe,
                fun(I) ->
                    _assert_subject@1 = gleam_community@maths@elementary:power(
                        Base,
                        I
                    ),
                    {ok, Result} = case _assert_subject@1 of
                        {ok, _} -> _assert_subject@1;
                        _assert_fail@1 ->
                            erlang:error(#{gleam_error => let_assert,
                                        message => <<"Assertion pattern match failed"/utf8>>,
                                        value => _assert_fail@1,
                                        module => <<"gleam_community/maths/sequences"/utf8>>,
                                        function => <<"logarithmic_space"/utf8>>,
                                        line => 224})
                    end,
                    Result
                end
            ),
            {ok, _pipe@1};

        false ->
            _pipe@2 = <<"Invalid input: num < 0. Valid input is num > 0."/utf8>>,
            {error, _pipe@2}
    end.

-spec geometric_space(float(), float(), integer(), boolean()) -> {ok,
        list(float())} |
    {error, binary()}.
geometric_space(Start, Stop, Num, Endpoint) ->
    case (Start =:= +0.0) orelse (Stop =:= +0.0) of
        true ->
            _pipe = <<""/utf8>>,
            {error, _pipe};

        false ->
            case Num > 0 of
                true ->
                    _assert_subject = gleam_community@maths@elementary:logarithm_10(
                        Start
                    ),
                    {ok, Log_start} = case _assert_subject of
                        {ok, _} -> _assert_subject;
                        _assert_fail ->
                            erlang:error(#{gleam_error => let_assert,
                                        message => <<"Assertion pattern match failed"/utf8>>,
                                        value => _assert_fail,
                                        module => <<"gleam_community/maths/sequences"/utf8>>,
                                        function => <<"geometric_space"/utf8>>,
                                        line => 293})
                    end,
                    _assert_subject@1 = gleam_community@maths@elementary:logarithm_10(
                        Stop
                    ),
                    {ok, Log_stop} = case _assert_subject@1 of
                        {ok, _} -> _assert_subject@1;
                        _assert_fail@1 ->
                            erlang:error(#{gleam_error => let_assert,
                                        message => <<"Assertion pattern match failed"/utf8>>,
                                        value => _assert_fail@1,
                                        module => <<"gleam_community/maths/sequences"/utf8>>,
                                        function => <<"geometric_space"/utf8>>,
                                        line => 294})
                    end,
                    logarithmic_space(Log_start, Log_stop, Num, Endpoint, 10.0);

                false ->
                    _pipe@1 = <<"Invalid input: num < 0. Valid input is num > 0."/utf8>>,
                    {error, _pipe@1}
            end
    end.

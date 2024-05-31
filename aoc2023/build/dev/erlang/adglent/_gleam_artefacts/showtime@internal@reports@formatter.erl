-module(showtime@internal@reports@formatter).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch]).

-export([create_test_report/1]).
-export_type([glee_unit_assertion_type/0, module_and_test/0, unified_error/0]).

-type glee_unit_assertion_type() :: {glee_unit_assert_equal, binary()} |
    {glee_unit_assert_not_equal, binary()} |
    {glee_unit_assert_match, binary()}.

-type module_and_test() :: {module_and_test_run,
        binary(),
        showtime@internal@common@test_suite:test_run()}.

-type unified_error() :: {unified_error,
        gleam@option:option(showtime@tests@meta:meta()),
        binary(),
        binary(),
        binary(),
        binary(),
        gleam@option:option(integer()),
        list(showtime@internal@common@test_result:trace())}.

-spec erlang_error_to_unified(
    list(showtime@internal@common@test_result:reason_detail()),
    glee_unit_assertion_type(),
    list(showtime@internal@common@test_result:trace())
) -> unified_error().
erlang_error_to_unified(Error_details, Assertion_type, Stacktrace) ->
    _pipe = Error_details,
    gleam@list:fold(
        _pipe,
        {unified_error,
            none,
            <<"not_set"/utf8>>,
            erlang:element(2, Assertion_type),
            <<""/utf8>>,
            <<""/utf8>>,
            none,
            Stacktrace},
        fun(Unified, Reason) -> case Reason of
                {expression, Expression} ->
                    erlang:setelement(3, Unified, Expression);

                {expected, Value} ->
                    case Assertion_type of
                        {glee_unit_assert_equal, _} ->
                            erlang:setelement(
                                5,
                                Unified,
                                showtime@internal@reports@styles:expected_highlight(
                                    gleam@string:inspect(Value)
                                )
                            );

                        _ ->
                            Unified
                    end;

                {value, Value@1} ->
                    case Assertion_type of
                        {glee_unit_assert_not_equal, _} ->
                            erlang:setelement(
                                6,
                                erlang:setelement(
                                    5,
                                    Unified,
                                    <<(showtime@internal@reports@styles:not_style(
                                            <<"not "/utf8>>
                                        ))/binary,
                                        (gleam@string:inspect(Value@1))/binary>>
                                ),
                                showtime@internal@reports@styles:got_highlight(
                                    gleam@string:inspect(Value@1)
                                )
                            );

                        _ ->
                            erlang:setelement(
                                6,
                                Unified,
                                showtime@internal@reports@styles:got_highlight(
                                    gleam@string:inspect(Value@1)
                                )
                            )
                    end;

                {pattern, Pattern} ->
                    case Pattern of
                        <<"{ ok , _ }"/utf8>> ->
                            erlang:setelement(
                                5,
                                Unified,
                                showtime@internal@reports@styles:expected_highlight(
                                    <<"Ok(_)"/utf8>>
                                )
                            );

                        <<"{ error , _ }"/utf8>> ->
                            erlang:setelement(
                                5,
                                Unified,
                                showtime@internal@reports@styles:expected_highlight(
                                    <<"Error(_)"/utf8>>
                                )
                            );

                        _ ->
                            Unified
                    end;

                _ ->
                    Unified
            end end
    ).

-spec gleam_error_to_unified(
    showtime@internal@common@test_result:gleam_error_detail(),
    list(showtime@internal@common@test_result:trace())
) -> unified_error().
gleam_error_to_unified(Gleam_error, Stacktrace) ->
    case Gleam_error of
        {let_assert, _, _, _, _, Value} ->
            Result = gleam@dynamic:unsafe_coerce(Value),
            {error, Assertion} = case Result of
                {error, _} -> Result;
                _assert_fail ->
                    erlang:error(#{gleam_error => let_assert,
                                message => <<"Assertion pattern match failed"/utf8>>,
                                value => _assert_fail,
                                module => <<"showtime/internal/reports/formatter"/utf8>>,
                                function => <<"gleam_error_to_unified"/utf8>>,
                                line => 293})
            end,
            case Assertion of
                {eq, Got, Expected, Meta} ->
                    {Expected@1, Got@1} = showtime@internal@reports@compare:compare(
                        Expected,
                        Got
                    ),
                    {unified_error,
                        Meta,
                        <<"assert"/utf8>>,
                        <<"Assert equal"/utf8>>,
                        Expected@1,
                        Got@1,
                        none,
                        Stacktrace};

                {not_eq, Got@2, Expected@2, Meta@1} ->
                    {unified_error,
                        Meta@1,
                        <<"assert"/utf8>>,
                        <<"Assert not equal"/utf8>>,
                        <<(showtime@internal@reports@styles:not_style(
                                <<"not "/utf8>>
                            ))/binary,
                            (gleam@string:inspect(Expected@2))/binary>>,
                        gleam@string:inspect(Got@2),
                        none,
                        Stacktrace};

                {is_ok, Got@3, Meta@2} ->
                    {unified_error,
                        Meta@2,
                        <<"assert"/utf8>>,
                        <<"Assert is Ok"/utf8>>,
                        showtime@internal@reports@styles:expected_highlight(
                            <<"Ok(_)"/utf8>>
                        ),
                        showtime@internal@reports@styles:got_highlight(
                            gleam@string:inspect(Got@3)
                        ),
                        none,
                        Stacktrace};

                {is_error, Got@4, Meta@3} ->
                    {unified_error,
                        Meta@3,
                        <<"assert"/utf8>>,
                        <<"Assert is Ok"/utf8>>,
                        showtime@internal@reports@styles:expected_highlight(
                            <<"Error(_)"/utf8>>
                        ),
                        showtime@internal@reports@styles:got_highlight(
                            gleam@string:inspect(Got@4)
                        ),
                        none,
                        Stacktrace};

                {fail, Meta@4} ->
                    {unified_error,
                        Meta@4,
                        <<"assert"/utf8>>,
                        <<"Assert is Ok"/utf8>>,
                        showtime@internal@reports@styles:got_highlight(
                            <<"should.fail()"/utf8>>
                        ),
                        showtime@internal@reports@styles:got_highlight(
                            <<"N/A - test always expected to fail"/utf8>>
                        ),
                        none,
                        Stacktrace}
            end
    end.

-spec format_reason(unified_error(), binary(), binary(), list(binary())) -> list(list(showtime@internal@reports@table:col())).
format_reason(Error, Module, Function, Output_buffer) ->
    Meta@1 = case erlang:element(2, Error) of
        {some, Meta} ->
            {some,
                [{align_right,
                        {styled_content,
                            showtime@internal@reports@styles:heading_style(
                                <<"Description"/utf8>>
                            )},
                        2},
                    {separator, <<": "/utf8>>},
                    {align_left, {content, erlang:element(2, Meta)}, 0}]};

        none ->
            none
    end,
    Stacktrace = begin
        _pipe = erlang:element(8, Error),
        gleam@list:map(_pipe, fun(Trace) -> case Trace of
                    {trace, Function@1, _, _} when Function@1 =:= <<""/utf8>> ->
                        <<"(anonymous)"/utf8>>;

                    {trace_module, Module@1, Function@2, _, _} when Function@2 =:= <<""/utf8>> ->
                        <<<<Module@1/binary, "."/utf8>>/binary,
                            "(anonymous)"/utf8>>;

                    {trace, Function@3, _, _} ->
                        Function@3;

                    {trace_module, Module@2, Function@4, _, _} ->
                        <<<<Module@2/binary, "."/utf8>>/binary,
                            Function@4/binary>>
                end end)
    end,
    Stacktrace_rows = case Stacktrace of
        [] ->
            [];

        [First | Rest] ->
            First_row = {some,
                [{align_right,
                        {styled_content,
                            showtime@internal@reports@styles:heading_style(
                                <<"Stacktrace"/utf8>>
                            )},
                        2},
                    {separator, <<": "/utf8>>},
                    {align_left,
                        {styled_content,
                            showtime@internal@reports@styles:stacktrace_style(
                                First
                            )},
                        0}]},
            Rest_rows = begin
                _pipe@1 = Rest,
                gleam@list:map(
                    _pipe@1,
                    fun(Row) ->
                        {some,
                            [{align_right, {content, <<""/utf8>>}, 2},
                                {separator, <<"  "/utf8>>},
                                {align_left,
                                    {styled_content,
                                        showtime@internal@reports@styles:stacktrace_style(
                                            Row
                                        )},
                                    0}]}
                    end
                )
            end,
            [First_row | Rest_rows]
    end,
    Output_rows = case begin
        _pipe@2 = Output_buffer,
        _pipe@3 = gleam@list:reverse(_pipe@2),
        gleam@list:map(
            _pipe@3,
            fun(Row@1) -> gleam@string:trim_right(Row@1) end
        )
    end of
        [] ->
            [];

        [First@1 | Rest@1] ->
            First_row@1 = {some,
                [{align_right,
                        {styled_content,
                            showtime@internal@reports@styles:heading_style(
                                <<"Output"/utf8>>
                            )},
                        2},
                    {separator, <<": "/utf8>>},
                    {align_left_overflow,
                        {styled_content,
                            showtime@internal@reports@styles:stacktrace_style(
                                First@1
                            )},
                        0}]},
            Rest_rows@1 = begin
                _pipe@4 = Rest@1,
                gleam@list:map(
                    _pipe@4,
                    fun(Row@2) ->
                        {some,
                            [{align_right, {content, <<""/utf8>>}, 2},
                                {separator, <<"  "/utf8>>},
                                {align_left_overflow,
                                    {styled_content,
                                        showtime@internal@reports@styles:stacktrace_style(
                                            Row@2
                                        )},
                                    0}]}
                    end
                )
            end,
            [First_row@1 | Rest_rows@1]
    end,
    Line@1 = begin
        _pipe@5 = erlang:element(7, Error),
        _pipe@6 = gleam@option:map(
            _pipe@5,
            fun(Line) -> <<":"/utf8, (gleam@int:to_string(Line))/binary>> end
        ),
        gleam@option:unwrap(_pipe@6, <<""/utf8>>)
    end,
    Arrow = <<(gleam@string:join(
            gleam@list:repeat(
                <<"-"/utf8>>,
                (gleam@string:length(Module) + 1) + ((gleam@string:length(
                    Function
                )
                + gleam@string:length(Line@1))
                div 2)
            ),
            <<""/utf8>>
        ))/binary,
        "⌄"/utf8>>,
    Standard_table_rows = [{some,
            [{align_right,
                    {styled_content,
                        showtime@internal@reports@styles:error_style(
                            <<"Failed"/utf8>>
                        )},
                    2},
                {separator, <<": "/utf8>>},
                {align_left, {content, Arrow}, 0}]},
        {some,
            [{align_right,
                    {styled_content,
                        showtime@internal@reports@styles:heading_style(
                            <<"Test"/utf8>>
                        )},
                    2},
                {separator, <<": "/utf8>>},
                {align_left,
                    {styled_content,
                        <<<<Module/binary, "."/utf8>>/binary,
                            (showtime@internal@reports@styles:function_style(
                                <<Function/binary, Line@1/binary>>
                            ))/binary>>},
                    0}]},
        Meta@1,
        {some,
            [{align_right,
                    {styled_content,
                        showtime@internal@reports@styles:heading_style(
                            <<"Expected"/utf8>>
                        )},
                    2},
                {separator, <<": "/utf8>>},
                {align_left_overflow,
                    {styled_content, erlang:element(5, Error)},
                    0}]},
        {some,
            [{align_right,
                    {styled_content,
                        showtime@internal@reports@styles:heading_style(
                            <<"Got"/utf8>>
                        )},
                    2},
                {separator, <<": "/utf8>>},
                {align_left_overflow,
                    {styled_content, erlang:element(6, Error)},
                    0}]}],
    _pipe@7 = Standard_table_rows,
    _pipe@8 = gleam@list:append(_pipe@7, Stacktrace_rows),
    _pipe@9 = gleam@list:append(_pipe@8, Output_rows),
    _pipe@10 = gleam@list:append(
        _pipe@9,
        [{some,
                [{align_right, {content, <<""/utf8>>}, 0},
                    {align_right, {content, <<""/utf8>>}, 0},
                    {align_right, {content, <<""/utf8>>}, 0}]}]
    ),
    gleam@list:filter_map(
        _pipe@10,
        fun(Row@3) -> gleam@option:to_result(Row@3, nil) end
    ).

-spec create_test_report(
    gleam@dict:dict(binary(), gleam@dict:dict(binary(), showtime@internal@common@test_suite:test_run()))
) -> {binary(), integer()}.
create_test_report(Test_results) ->
    All_test_runs = begin
        _pipe = Test_results,
        _pipe@1 = gleam@map:values(_pipe),
        gleam@list:flat_map(_pipe@1, fun gleam@map:values/1)
    end,
    Failed_test_runs = begin
        _pipe@2 = Test_results,
        _pipe@3 = gleam@map:to_list(_pipe@2),
        gleam@list:flat_map(
            _pipe@3,
            fun(Entry) ->
                {Module_name, Test_module_results} = Entry,
                _pipe@4 = Test_module_results,
                _pipe@5 = gleam@map:values(_pipe@4),
                gleam@list:filter_map(_pipe@5, fun(Test_run) -> case Test_run of
                            {completed_test_run, _, _, Result} ->
                                case Result of
                                    {error, _} ->
                                        {ok,
                                            {module_and_test_run,
                                                Module_name,
                                                Test_run}};

                                    {ok, {ignored, _}} ->
                                        {error, nil};

                                    {ok, _} ->
                                        {error, nil}
                                end;

                            _ ->
                                _pipe@6 = Test_run,
                                gleam@io:debug(_pipe@6),
                                {error, nil}
                        end end)
            end
        )
    end,
    Ignored_test_runs = begin
        _pipe@7 = Test_results,
        _pipe@8 = gleam@map:to_list(_pipe@7),
        gleam@list:flat_map(
            _pipe@8,
            fun(Entry@1) ->
                {Module_name@1, Test_module_results@1} = Entry@1,
                _pipe@9 = Test_module_results@1,
                _pipe@10 = gleam@map:values(_pipe@9),
                gleam@list:filter_map(
                    _pipe@10,
                    fun(Test_run@1) -> case Test_run@1 of
                            {completed_test_run, Test_function, _, Result@1} ->
                                case Result@1 of
                                    {ok, {ignored, Reason}} ->
                                        {ok,
                                            {<<<<Module_name@1/binary,
                                                        "."/utf8>>/binary,
                                                    (erlang:element(
                                                        2,
                                                        Test_function
                                                    ))/binary>>,
                                                Reason}};

                                    _ ->
                                        {error, nil}
                                end;

                            _ ->
                                {error, nil}
                        end end
                )
            end
        )
    end,
    Failed_tests_report = begin
        _pipe@11 = Failed_test_runs,
        _pipe@12 = gleam@list:filter_map(
            _pipe@11,
            fun(Module_and_test_run) ->
                case erlang:element(3, Module_and_test_run) of
                    {completed_test_run, Test_function@1, _, Result@2} ->
                        case Result@2 of
                            {error, Exception} ->
                                case erlang:element(3, Exception) of
                                    {assert_equal, Reason_details} ->
                                        {ok,
                                            format_reason(
                                                erlang_error_to_unified(
                                                    Reason_details,
                                                    {glee_unit_assert_equal,
                                                        <<"Assert equal"/utf8>>},
                                                    erlang:element(
                                                        2,
                                                        erlang:element(
                                                            4,
                                                            Exception
                                                        )
                                                    )
                                                ),
                                                erlang:element(
                                                    2,
                                                    Module_and_test_run
                                                ),
                                                erlang:element(
                                                    2,
                                                    Test_function@1
                                                ),
                                                erlang:element(5, Exception)
                                            )};

                                    {assert_not_equal, Reason_details@1} ->
                                        {ok,
                                            format_reason(
                                                erlang_error_to_unified(
                                                    Reason_details@1,
                                                    {glee_unit_assert_not_equal,
                                                        <<"Assert not equal"/utf8>>},
                                                    erlang:element(
                                                        2,
                                                        erlang:element(
                                                            4,
                                                            Exception
                                                        )
                                                    )
                                                ),
                                                erlang:element(
                                                    2,
                                                    Module_and_test_run
                                                ),
                                                erlang:element(
                                                    2,
                                                    Test_function@1
                                                ),
                                                erlang:element(5, Exception)
                                            )};

                                    {assert_match, Reason_details@2} ->
                                        {ok,
                                            format_reason(
                                                erlang_error_to_unified(
                                                    Reason_details@2,
                                                    {glee_unit_assert_match,
                                                        <<"Assert match"/utf8>>},
                                                    erlang:element(
                                                        2,
                                                        erlang:element(
                                                            4,
                                                            Exception
                                                        )
                                                    )
                                                ),
                                                erlang:element(
                                                    2,
                                                    Module_and_test_run
                                                ),
                                                erlang:element(
                                                    2,
                                                    Test_function@1
                                                ),
                                                erlang:element(5, Exception)
                                            )};

                                    {gleam_error, Reason@1} ->
                                        {ok,
                                            format_reason(
                                                gleam_error_to_unified(
                                                    Reason@1,
                                                    erlang:element(
                                                        2,
                                                        erlang:element(
                                                            4,
                                                            Exception
                                                        )
                                                    )
                                                ),
                                                erlang:element(
                                                    2,
                                                    Module_and_test_run
                                                ),
                                                erlang:element(
                                                    2,
                                                    Test_function@1
                                                ),
                                                erlang:element(5, Exception)
                                            )};

                                    {gleam_assert, Value, Line_no} ->
                                        {ok,
                                            format_reason(
                                                {unified_error,
                                                    none,
                                                    <<"gleam assert"/utf8>>,
                                                    <<"Assert failed"/utf8>>,
                                                    <<"Patterns should match"/utf8>>,
                                                    showtime@internal@reports@styles:error_style(
                                                        gleam@string:inspect(
                                                            Value
                                                        )
                                                    ),
                                                    {some, Line_no},
                                                    erlang:element(
                                                        2,
                                                        erlang:element(
                                                            4,
                                                            Exception
                                                        )
                                                    )},
                                                erlang:element(
                                                    2,
                                                    Module_and_test_run
                                                ),
                                                erlang:element(
                                                    2,
                                                    Test_function@1
                                                ),
                                                erlang:element(5, Exception)
                                            )};

                                    {generic_exception, Value@1} ->
                                        {ok,
                                            format_reason(
                                                {unified_error,
                                                    none,
                                                    <<"generic exception"/utf8>>,
                                                    <<"Test function threw an exception"/utf8>>,
                                                    <<"Exception in test function"/utf8>>,
                                                    showtime@internal@reports@styles:error_style(
                                                        gleam@string:inspect(
                                                            Value@1
                                                        )
                                                    ),
                                                    none,
                                                    erlang:element(
                                                        2,
                                                        erlang:element(
                                                            4,
                                                            Exception
                                                        )
                                                    )},
                                                erlang:element(
                                                    2,
                                                    Module_and_test_run
                                                ),
                                                erlang:element(
                                                    2,
                                                    Test_function@1
                                                ),
                                                erlang:element(5, Exception)
                                            )};

                                    Other ->
                                        gleam@io:println(
                                            <<"Other: "/utf8,
                                                (gleam@string:inspect(Other))/binary>>
                                        ),
                                        erlang:error(#{gleam_error => panic,
                                                message => <<"panic expression evaluated"/utf8>>,
                                                module => <<"showtime/internal/reports/formatter"/utf8>>,
                                                function => <<"create_test_report"/utf8>>,
                                                line => 178}),
                                        {error, nil}
                                end;

                            _ ->
                                {error, nil}
                        end;

                    _ ->
                        {error, nil}
                end
            end
        ),
        gleam@list:fold(
            _pipe@12,
            [],
            fun(Rows, Test_rows) -> gleam@list:append(Rows, Test_rows) end
        )
    end,
    All_test_execution_time_reports = begin
        _pipe@13 = All_test_runs,
        gleam@list:filter_map(_pipe@13, fun(Test_run@2) -> case Test_run@2 of
                    {completed_test_run, Test_function@2, Total_time, _} ->
                        {ok,
                            <<<<<<(erlang:element(2, Test_function@2))/binary,
                                        ": "/utf8>>/binary,
                                    (gleam@int:to_string(Total_time))/binary>>/binary,
                                " ms"/utf8>>};

                    _ ->
                        {error, nil}
                end end)
    end,
    _ = begin
        _pipe@14 = All_test_execution_time_reports,
        gleam@string:join(_pipe@14, <<"\n"/utf8>>)
    end,
    All_tests_count = begin
        _pipe@15 = All_test_runs,
        gleam@list:length(_pipe@15)
    end,
    Ignored_tests_count = begin
        _pipe@16 = Ignored_test_runs,
        gleam@list:length(_pipe@16)
    end,
    Failed_tests_count = begin
        _pipe@17 = Failed_test_runs,
        gleam@list:length(_pipe@17)
    end,
    Passed = showtime@internal@reports@styles:passed_style(
        <<(gleam@int:to_string(
                (All_tests_count - Failed_tests_count) - Ignored_tests_count
            ))/binary,
            " passed"/utf8>>
    ),
    Failed = showtime@internal@reports@styles:failed_style(
        <<(gleam@int:to_string(Failed_tests_count))/binary, " failed"/utf8>>
    ),
    Ignored = case Ignored_tests_count of
        0 ->
            <<""/utf8>>;

        _ ->
            <<", "/utf8,
                (showtime@internal@reports@styles:ignored_style(
                    <<(gleam@int:to_string(Ignored_tests_count))/binary,
                        " ignored"/utf8>>
                ))/binary>>
    end,
    Failed_tests_table = begin
        _pipe@18 = {table, none, Failed_tests_report},
        _pipe@19 = showtime@internal@reports@table:align_table(_pipe@18),
        showtime@internal@reports@table:to_string(_pipe@19)
    end,
    Test_report = <<<<<<<<<<<<"\n"/utf8, Failed_tests_table/binary>>/binary,
                        "\n"/utf8>>/binary,
                    Passed/binary>>/binary,
                ", "/utf8>>/binary,
            Failed/binary>>/binary,
        Ignored/binary>>,
    {Test_report, Failed_tests_count}.

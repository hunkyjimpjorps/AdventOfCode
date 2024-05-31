-module(showtime@internal@erlang@module_handler).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch]).

-export([start/5]).

-spec start(
    fun((showtime@internal@common@test_suite:test_event()) -> nil),
    fun((showtime@internal@common@test_suite:test_module()) -> showtime@internal@common@test_suite:test_suite()),
    fun((showtime@internal@common@test_suite:test_suite(), fun((showtime@internal@common@test_suite:test_event()) -> nil), list(binary()), showtime@internal@common@cli:capture()) -> nil),
    list(binary()),
    showtime@internal@common@cli:capture()
) -> fun((showtime@internal@common@test_suite:test_module()) -> nil).
start(
    Test_event_handler,
    Test_function_collector,
    Run_test_suite,
    Ignore_tags,
    Capture
) ->
    _assert_subject = gleam@otp@actor:start(
        nil,
        fun(Module, State) ->
            gleam@erlang@process:start(
                fun() ->
                    Test_suite = Test_function_collector(Module),
                    Test_event_handler({start_test_suite, Module}),
                    Run_test_suite(
                        Test_suite,
                        Test_event_handler,
                        Ignore_tags,
                        Capture
                    ),
                    Test_event_handler({end_test_suite, Module})
                end,
                false
            ),
            {continue, State, none}
        end
    ),
    {ok, Subject} = case _assert_subject of
        {ok, _} -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail,
                        module => <<"showtime/internal/erlang/module_handler"/utf8>>,
                        function => <<"start"/utf8>>,
                        line => 23})
    end,
    fun(Test_module) ->
        gleam@erlang@process:send(Subject, Test_module),
        nil
    end.

-module(showtime@internal@erlang@runner).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch]).

-export([run_test/4, run_test_suite/4]).

-spec run_test(
    binary(),
    binary(),
    list(binary()),
    showtime@internal@common@cli:capture()
) -> {ok, showtime@internal@common@test_result:test_return()} |
    {error, showtime@internal@common@test_result:exception()}.
run_test(Module_name, Test_name, Ignore_tags, Capture) ->
    Result = showtime_ffi:run_test(
        erlang:binary_to_atom(Module_name),
        erlang:binary_to_atom(Test_name),
        Ignore_tags,
        Capture
    ),
    Result.

-spec run_test_suite(
    showtime@internal@common@test_suite:test_suite(),
    fun((showtime@internal@common@test_suite:test_event()) -> nil),
    list(binary()),
    showtime@internal@common@cli:capture()
) -> nil.
run_test_suite(Test_suite, Test_event_handler, Ignore_tags, Capture) ->
    _pipe = erlang:element(3, Test_suite),
    gleam@list:each(
        _pipe,
        fun(Test) ->
            Test_event_handler(
                {start_test, erlang:element(2, Test_suite), Test}
            ),
            Result = run_test(
                erlang:element(2, erlang:element(2, Test_suite)),
                erlang:element(2, Test),
                Ignore_tags,
                Capture
            ),
            Test_event_handler(
                {end_test, erlang:element(2, Test_suite), Test, Result}
            )
        end
    ).

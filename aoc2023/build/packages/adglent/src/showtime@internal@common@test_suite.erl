-module(showtime@internal@common@test_suite).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function]).

-export_type([test_run/0, test_module/0, test_function/0, test_suite/0, test_event/0]).

-type test_run() :: {ongoing_test_run, test_function(), integer()} |
    {completed_test_run,
        test_function(),
        integer(),
        {ok, showtime@internal@common@test_result:test_return()} |
            {error, showtime@internal@common@test_result:exception()}}.

-type test_module() :: {test_module, binary(), gleam@option:option(binary())}.

-type test_function() :: {test_function, binary()}.

-type test_suite() :: {test_suite, test_module(), list(test_function())}.

-type test_event() :: start_test_run |
    {start_test_suite, test_module()} |
    {start_test, test_module(), test_function()} |
    {end_test,
        test_module(),
        test_function(),
        {ok, showtime@internal@common@test_result:test_return()} |
            {error, showtime@internal@common@test_result:exception()}} |
    {end_test_suite, test_module()} |
    {end_test_run, integer()}.



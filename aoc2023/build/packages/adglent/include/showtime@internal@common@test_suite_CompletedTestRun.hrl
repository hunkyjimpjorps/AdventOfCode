-record(completed_test_run, {
    test_function :: showtime@internal@common@test_suite:test_function(),
    total_time :: integer(),
    result :: {ok, showtime@internal@common@test_result:test_return()} |
        {error, showtime@internal@common@test_result:exception()}
}).

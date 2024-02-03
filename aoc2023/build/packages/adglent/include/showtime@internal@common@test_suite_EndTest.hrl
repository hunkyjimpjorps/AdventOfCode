-record(end_test, {
    test_module :: showtime@internal@common@test_suite:test_module(),
    test_function :: showtime@internal@common@test_suite:test_function(),
    result :: {ok, showtime@internal@common@test_result:test_return()} |
        {error, showtime@internal@common@test_result:exception()}
}).

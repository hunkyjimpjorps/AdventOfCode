-record(handler_state, {
    test_state :: showtime@internal@common@common_event_handler:test_state(),
    num_done :: integer(),
    events :: gleam@map:map_(binary(), gleam@map:map_(binary(), showtime@internal@common@test_suite:test_run()))
}).

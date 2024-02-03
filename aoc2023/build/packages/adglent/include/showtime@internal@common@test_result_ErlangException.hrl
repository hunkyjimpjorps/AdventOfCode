-record(erlang_exception, {
    class :: showtime@internal@common@test_result:class(),
    reason :: showtime@internal@common@test_result:reason(),
    stacktrace :: showtime@internal@common@test_result:trace_list(),
    output_buffer :: list(binary())
}).

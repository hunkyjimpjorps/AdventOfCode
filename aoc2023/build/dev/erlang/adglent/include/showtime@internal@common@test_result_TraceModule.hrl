-record(trace_module, {
    module :: binary(),
    function :: binary(),
    arity :: showtime@internal@common@test_result:arity_(),
    extra_info :: list(showtime@internal@common@test_result:extra_info())
}).

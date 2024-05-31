-record(flag_builder, {
    desc :: binary(),
    parser :: fun((binary()) -> {ok, any()} | {error, snag:snag()}),
    value :: fun((glint@flag:internal(any())) -> glint@flag:value()),
    default :: gleam@option:option(any())
}).

-record(internal, {
    value :: gleam@option:option(any()),
    parser :: fun((binary()) -> {ok, any()} | {error, snag:snag()})
}).

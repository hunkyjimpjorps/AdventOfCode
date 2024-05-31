-record(is_error, {
    a :: {ok, any()} | {error, any()},
    meta :: gleam@option:option(showtime@tests@meta:meta())
}).

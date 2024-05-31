-record(is_ok, {
    a :: {ok, any()} | {error, any()},
    meta :: gleam@option:option(showtime@tests@meta:meta())
}).

-record(part, {
    acc :: binary(),
    part :: list(any()),
    highlight :: fun((binary()) -> binary())
}).

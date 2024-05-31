-record(highlighters, {
    first :: fun((binary()) -> binary()),
    second :: fun((binary()) -> binary()),
    matching :: fun((binary()) -> binary())
}).

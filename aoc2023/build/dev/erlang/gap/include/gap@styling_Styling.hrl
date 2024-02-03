-record(styling, {
    comparison :: gap@comparison:comparison(any()),
    serializer :: gleam@option:option(fun((gap@styling:part(any())) -> binary())),
    highlight :: gleam@option:option(gap@styling:highlighters())
}).

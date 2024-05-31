-record(stub, {
    path :: list(binary()),
    run :: fun((glint:command_input()) -> any()),
    flags :: list({binary(), glint@flag:flag()}),
    description :: binary()
}).

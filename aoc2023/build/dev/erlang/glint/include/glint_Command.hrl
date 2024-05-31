-record(command, {
    do :: fun((glint:command_input()) -> any()),
    flags :: gleam@dict:dict(binary(), glint@flag:flag()),
    description :: binary()
}).

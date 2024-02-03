-record(command, {
    do :: fun((glint:command_input()) -> any()),
    flags :: gleam@map:map_(binary(), glint@flag:flag()),
    description :: binary()
}).

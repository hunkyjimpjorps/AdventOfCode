-record(command_input, {
    args :: list(binary()),
    flags :: gleam@map:map_(binary(), glint@flag:flag())
}).

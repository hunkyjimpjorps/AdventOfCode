-record(command_input, {
    args :: list(binary()),
    flags :: gleam@dict:dict(binary(), glint@flag:flag())
}).

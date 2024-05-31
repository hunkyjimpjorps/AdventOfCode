-record(glint, {
    config :: glint:config(),
    cmd :: glint:command_node(any()),
    global_flags :: gleam@dict:dict(binary(), glint@flag:flag())
}).

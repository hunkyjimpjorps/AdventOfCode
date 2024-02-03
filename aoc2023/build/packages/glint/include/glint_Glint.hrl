-record(glint, {
    config :: glint:config(),
    cmd :: glint:command_node(any()),
    global_flags :: gleam@map:map_(binary(), glint@flag:flag())
}).

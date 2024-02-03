-module(glint).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function]).

-export([with_config/2, with_pretty_help/2, without_pretty_help/1, with_name/2, new/0, command/1, description/2, flag/3, flag_tuple/2, flags/2, global_flag/3, global_flag_tuple/2, global_flags/2, default_pretty_help/0, add/3, help_flag/0, execute/2, run_and_handle/3, run/2, add_command_from_stub/2]).
-export_type([config/0, pretty_help/0, glint/1, command/1, command_input/0, command_node/1, out/1, stub/1]).

-type config() :: {config,
        gleam@option:option(pretty_help()),
        gleam@option:option(binary())}.

-type pretty_help() :: {pretty_help,
        gleam_community@colour:colour(),
        gleam_community@colour:colour(),
        gleam_community@colour:colour()}.

-opaque glint(JFP) :: {glint,
        config(),
        command_node(JFP),
        gleam@dict:dict(binary(), glint@flag:flag())}.

-opaque command(JFQ) :: {command,
        fun((command_input()) -> JFQ),
        gleam@dict:dict(binary(), glint@flag:flag()),
        binary()}.

-type command_input() :: {command_input,
        list(binary()),
        gleam@dict:dict(binary(), glint@flag:flag())}.

-type command_node(JFR) :: {command_node,
        gleam@option:option(command(JFR)),
        gleam@dict:dict(binary(), command_node(JFR))}.

-type out(JFS) :: {out, JFS} | {help, binary()}.

-type stub(JFT) :: {stub,
        list(binary()),
        fun((command_input()) -> JFT),
        list({binary(), glint@flag:flag()}),
        binary()}.

-spec with_config(glint(JFY), config()) -> glint(JFY).
with_config(Glint, Config) ->
    erlang:setelement(2, Glint, Config).

-spec with_pretty_help(glint(JGB), pretty_help()) -> glint(JGB).
with_pretty_help(Glint, Pretty) ->
    _pipe = erlang:setelement(2, erlang:element(2, Glint), {some, Pretty}),
    with_config(Glint, _pipe).

-spec without_pretty_help(glint(JGE)) -> glint(JGE).
without_pretty_help(Glint) ->
    _pipe = erlang:setelement(2, erlang:element(2, Glint), none),
    with_config(Glint, _pipe).

-spec with_name(glint(JGH), binary()) -> glint(JGH).
with_name(Glint, Name) ->
    _pipe = erlang:setelement(3, erlang:element(2, Glint), {some, Name}),
    with_config(Glint, _pipe).

-spec empty_command() -> command_node(any()).
empty_command() ->
    {command_node, none, gleam@map:new()}.

-spec new() -> glint(any()).
new() ->
    {glint, {config, none, none}, empty_command(), gleam@map:new()}.

-spec do_add(command_node(JGR), list(binary()), command(JGR)) -> command_node(JGR).
do_add(Root, Path, Contents) ->
    case Path of
        [] ->
            erlang:setelement(2, Root, {some, Contents});

        [X | Xs] ->
            erlang:setelement(
                3,
                Root,
                (gleam@map:update(
                    erlang:element(3, Root),
                    X,
                    fun(Node) -> _pipe = Node,
                        _pipe@1 = gleam@option:lazy_unwrap(
                            _pipe,
                            fun empty_command/0
                        ),
                        do_add(_pipe@1, Xs, Contents) end
                ))
            )
    end.

-spec command(fun((command_input()) -> JHA)) -> command(JHA).
command(Runner) ->
    {command, Runner, gleam@map:new(), <<""/utf8>>}.

-spec description(command(JHD), binary()) -> command(JHD).
description(Cmd, Description) ->
    erlang:setelement(4, Cmd, Description).

-spec flag(command(JHG), binary(), glint@flag:flag_builder(any())) -> command(JHG).
flag(Cmd, Key, Flag) ->
    erlang:setelement(
        3,
        Cmd,
        gleam@map:insert(erlang:element(3, Cmd), Key, glint@flag:build(Flag))
    ).

-spec flag_tuple(command(JHL), {binary(), glint@flag:flag_builder(any())}) -> command(JHL).
flag_tuple(Cmd, Tup) ->
    flag(Cmd, erlang:element(1, Tup), erlang:element(2, Tup)).

-spec flags(command(JHQ), list({binary(), glint@flag:flag()})) -> command(JHQ).
flags(Cmd, Flags) ->
    gleam@list:fold(
        Flags,
        Cmd,
        fun(Cmd@1, _use1) ->
            {Key, Flag} = _use1,
            erlang:setelement(
                3,
                Cmd@1,
                gleam@map:insert(erlang:element(3, Cmd@1), Key, Flag)
            )
        end
    ).

-spec global_flag(glint(JHU), binary(), glint@flag:flag_builder(any())) -> glint(JHU).
global_flag(Glint, Key, Flag) ->
    erlang:setelement(
        4,
        Glint,
        gleam@map:insert(erlang:element(4, Glint), Key, glint@flag:build(Flag))
    ).

-spec global_flag_tuple(glint(JHZ), {binary(), glint@flag:flag_builder(any())}) -> glint(JHZ).
global_flag_tuple(Glint, Tup) ->
    global_flag(Glint, erlang:element(1, Tup), erlang:element(2, Tup)).

-spec global_flags(glint(JIE), list({binary(), glint@flag:flag()})) -> glint(JIE).
global_flags(Glint, Flags) ->
    erlang:setelement(
        4,
        Glint,
        (gleam@list:fold(
            Flags,
            erlang:element(4, Glint),
            fun(Acc, Tup) ->
                gleam@map:insert(
                    Acc,
                    erlang:element(1, Tup),
                    erlang:element(2, Tup)
                )
            end
        ))
    ).

-spec execute_root(
    command_node(JIS),
    gleam@dict:dict(binary(), glint@flag:flag()),
    list(binary()),
    list(binary())
) -> {ok, out(JIS)} | {error, snag:snag()}.
execute_root(Cmd, Global_flags, Args, Flag_inputs) ->
    _pipe@3 = case erlang:element(2, Cmd) of
        {some, Contents} ->
            gleam@result:'try'(
                gleam@list:try_fold(
                    Flag_inputs,
                    gleam@map:merge(Global_flags, erlang:element(3, Contents)),
                    fun glint@flag:update_flags/2
                ),
                fun(New_flags) -> _pipe = {command_input, Args, New_flags},
                    _pipe@1 = (erlang:element(2, Contents))(_pipe),
                    _pipe@2 = {out, _pipe@1},
                    {ok, _pipe@2} end
            );

        none ->
            snag:error(<<"command not found"/utf8>>)
    end,
    snag:context(_pipe@3, <<"failed to run command"/utf8>>).

-spec default_pretty_help() -> pretty_help().
default_pretty_help() ->
    _assert_subject = gleam_community@colour:from_rgb255(182, 255, 234),
    {ok, Usage_colour} = case _assert_subject of
        {ok, _} -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail,
                        module => <<"glint"/utf8>>,
                        function => <<"default_pretty_help"/utf8>>,
                        line => 404})
    end,
    _assert_subject@1 = gleam_community@colour:from_rgb255(255, 175, 243),
    {ok, Flags_colour} = case _assert_subject@1 of
        {ok, _} -> _assert_subject@1;
        _assert_fail@1 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail@1,
                        module => <<"glint"/utf8>>,
                        function => <<"default_pretty_help"/utf8>>,
                        line => 405})
    end,
    _assert_subject@2 = gleam_community@colour:from_rgb255(252, 226, 174),
    {ok, Subcommands_colour} = case _assert_subject@2 of
        {ok, _} -> _assert_subject@2;
        _assert_fail@2 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail@2,
                        module => <<"glint"/utf8>>,
                        function => <<"default_pretty_help"/utf8>>,
                        line => 406})
    end,
    {pretty_help, Usage_colour, Flags_colour, Subcommands_colour}.

-spec is_not_empty(binary()) -> boolean().
is_not_empty(S) ->
    S /= <<""/utf8>>.

-spec sanitize_path(list(binary())) -> list(binary()).
sanitize_path(Path) ->
    _pipe = Path,
    _pipe@1 = gleam@list:map(_pipe, fun gleam@string:trim/1),
    gleam@list:filter(_pipe@1, fun is_not_empty/1).

-spec add(glint(JGM), list(binary()), command(JGM)) -> glint(JGM).
add(Glint, Path, Contents) ->
    erlang:setelement(
        3,
        Glint,
        begin
            _pipe = Path,
            _pipe@1 = sanitize_path(_pipe),
            do_add(erlang:element(3, Glint), _pipe@1, Contents)
        end
    ).

-spec help_flag() -> binary().
help_flag() ->
    <<(<<"--"/utf8>>)/binary, "help"/utf8>>.

-spec wrap_with_space(binary()) -> binary().
wrap_with_space(S) ->
    case S of
        <<""/utf8>> ->
            <<" "/utf8>>;

        _ ->
            <<<<" "/utf8, S/binary>>/binary, " "/utf8>>
    end.

-spec subcommand_help(binary(), command_node(any())) -> binary().
subcommand_help(Name, Cmd) ->
    case erlang:element(2, Cmd) of
        none ->
            Name;

        {some, Contents} ->
            <<<<Name/binary, "\t\t"/utf8>>/binary,
                (erlang:element(4, Contents))/binary>>
    end.

-spec subcommands_help(gleam@dict:dict(binary(), command_node(any()))) -> binary().
subcommands_help(Cmds) ->
    _pipe = Cmds,
    _pipe@1 = gleam@map:map_values(_pipe, fun subcommand_help/2),
    _pipe@2 = gleam@map:values(_pipe@1),
    _pipe@3 = gleam@list:sort(_pipe@2, fun gleam@string:compare/2),
    gleam@string:join(_pipe@3, <<"\n\t"/utf8>>).

-spec heading_style(binary(), gleam_community@colour:colour()) -> binary().
heading_style(Heading, Colour) ->
    _pipe = Heading,
    _pipe@1 = gleam_community@ansi:bold(_pipe),
    _pipe@2 = gleam_community@ansi:underline(_pipe@1),
    _pipe@3 = gleam_community@ansi:italic(_pipe@2),
    _pipe@4 = gleam_community@ansi:hex(
        _pipe@3,
        gleam_community@colour:to_rgb_hex(Colour)
    ),
    gleam_community@ansi:reset(_pipe@4).

-spec usage_help(
    binary(),
    gleam@dict:dict(binary(), glint@flag:flag()),
    config()
) -> binary().
usage_help(Cmd_name, Flags, Config) ->
    App_name = gleam@option:unwrap(
        erlang:element(3, Config),
        <<"gleam run"/utf8>>
    ),
    Flags@1 = begin
        _pipe = Flags,
        _pipe@1 = gleam@map:to_list(_pipe),
        _pipe@2 = gleam@list:map(_pipe@1, fun glint@flag:flag_type_help/1),
        gleam@list:sort(_pipe@2, fun gleam@string:compare/2)
    end,
    Flag_sb = case Flags@1 of
        [] ->
            gleam@string_builder:new();

        _ ->
            _pipe@3 = Flags@1,
            _pipe@4 = gleam@list:intersperse(_pipe@3, <<" "/utf8>>),
            _pipe@5 = gleam@string_builder:from_strings(_pipe@4),
            _pipe@6 = gleam@string_builder:prepend(_pipe@5, <<" [ "/utf8>>),
            gleam@string_builder:append(_pipe@6, <<" ]"/utf8>>)
    end,
    _pipe@7 = [App_name, wrap_with_space(Cmd_name), <<"[ ARGS ]"/utf8>>],
    _pipe@8 = gleam@string_builder:from_strings(_pipe@7),
    _pipe@9 = gleam@string_builder:append_builder(_pipe@8, Flag_sb),
    _pipe@12 = gleam@string_builder:prepend(
        _pipe@9,
        <<(begin
                _pipe@10 = erlang:element(2, Config),
                _pipe@11 = gleam@option:map(
                    _pipe@10,
                    fun(Styling) ->
                        heading_style(
                            <<"USAGE:"/utf8>>,
                            erlang:element(2, Styling)
                        )
                    end
                ),
                gleam@option:unwrap(_pipe@11, <<"USAGE:"/utf8>>)
            end)/binary,
            "\n\t"/utf8>>
    ),
    gleam@string_builder:to_string(_pipe@12).

-spec cmd_help(
    list(binary()),
    command_node(any()),
    config(),
    gleam@dict:dict(binary(), glint@flag:flag())
) -> binary().
cmd_help(Path, Cmd, Config, Global_flags) ->
    Name = begin
        _pipe = Path,
        _pipe@1 = gleam@list:reverse(_pipe),
        gleam@string:join(_pipe@1, <<" "/utf8>>)
    end,
    Flags = begin
        _pipe@2 = gleam@option:map(
            erlang:element(2, Cmd),
            fun(Contents) -> erlang:element(3, Contents) end
        ),
        _pipe@3 = gleam@option:lazy_unwrap(_pipe@2, fun gleam@map:new/0),
        gleam@map:merge(Global_flags, _pipe@3)
    end,
    Flags_help_body = <<<<(begin
                _pipe@4 = erlang:element(2, Config),
                _pipe@5 = gleam@option:map(
                    _pipe@4,
                    fun(P) ->
                        heading_style(<<"FLAGS:"/utf8>>, erlang:element(3, P))
                    end
                ),
                gleam@option:unwrap(_pipe@5, <<"FLAGS:"/utf8>>)
            end)/binary,
            "\n\t"/utf8>>/binary,
        (gleam@string:join(
            gleam@list:sort(
                [<<"--help\t\t\tPrint help information"/utf8>> |
                    glint@flag:flags_help(Flags)],
                fun gleam@string:compare/2
            ),
            <<"\n\t"/utf8>>
        ))/binary>>,
    Usage = usage_help(Name, Flags, Config),
    Description = begin
        _pipe@6 = erlang:element(2, Cmd),
        _pipe@7 = gleam@option:map(
            _pipe@6,
            fun(Contents@1) -> erlang:element(4, Contents@1) end
        ),
        gleam@option:unwrap(_pipe@7, <<""/utf8>>)
    end,
    Header_items = begin
        _pipe@8 = [Name, Description],
        _pipe@9 = gleam@list:filter(_pipe@8, fun is_not_empty/1),
        gleam@string:join(_pipe@9, <<"\n"/utf8>>)
    end,
    Subcommands = case subcommands_help(erlang:element(3, Cmd)) of
        <<""/utf8>> ->
            <<""/utf8>>;

        Subcommands_help_body ->
            <<<<(begin
                        _pipe@10 = erlang:element(2, Config),
                        _pipe@11 = gleam@option:map(
                            _pipe@10,
                            fun(P@1) ->
                                heading_style(
                                    <<"SUBCOMMANDS:"/utf8>>,
                                    erlang:element(4, P@1)
                                )
                            end
                        ),
                        gleam@option:unwrap(_pipe@11, <<"SUBCOMMANDS:"/utf8>>)
                    end)/binary,
                    "\n\t"/utf8>>/binary,
                Subcommands_help_body/binary>>
    end,
    _pipe@12 = [Header_items, Usage, Flags_help_body, Subcommands],
    _pipe@13 = gleam@list:filter(_pipe@12, fun is_not_empty/1),
    gleam@string:join(_pipe@13, <<"\n\n"/utf8>>).

-spec do_execute(
    command_node(JIM),
    config(),
    gleam@dict:dict(binary(), glint@flag:flag()),
    list(binary()),
    list(binary()),
    boolean(),
    list(binary())
) -> {ok, out(JIM)} | {error, snag:snag()}.
do_execute(Cmd, Config, Global_flags, Args, Flags, Help, Command_path) ->
    case Args of
        [] when Help ->
            _pipe = Command_path,
            _pipe@1 = cmd_help(_pipe, Cmd, Config, Global_flags),
            _pipe@2 = {help, _pipe@1},
            {ok, _pipe@2};

        [] ->
            execute_root(Cmd, Global_flags, [], Flags);

        [Arg | Rest] ->
            case gleam@map:get(erlang:element(3, Cmd), Arg) of
                {ok, Cmd@1} ->
                    do_execute(
                        Cmd@1,
                        Config,
                        Global_flags,
                        Rest,
                        Flags,
                        Help,
                        [Arg | Command_path]
                    );

                _ when Help ->
                    _pipe@3 = Command_path,
                    _pipe@4 = cmd_help(_pipe@3, Cmd, Config, Global_flags),
                    _pipe@5 = {help, _pipe@4},
                    {ok, _pipe@5};

                _ ->
                    execute_root(Cmd, Global_flags, Args, Flags)
            end
    end.

-spec execute(glint(JII), list(binary())) -> {ok, out(JII)} |
    {error, snag:snag()}.
execute(Glint, Args) ->
    Help_flag = help_flag(),
    {Help, Args@2} = case gleam@list:pop(Args, fun(S) -> S =:= Help_flag end) of
        {ok, {_, Args@1}} ->
            {true, Args@1};

        _ ->
            {false, Args}
    end,
    {Flags, Args@3} = gleam@list:partition(
        Args@2,
        fun(_capture) -> gleam@string:starts_with(_capture, <<"--"/utf8>>) end
    ),
    do_execute(
        erlang:element(3, Glint),
        erlang:element(2, Glint),
        erlang:element(4, Glint),
        Args@3,
        Flags,
        Help,
        []
    ).

-spec run_and_handle(glint(JJA), list(binary()), fun((JJA) -> any())) -> nil.
run_and_handle(Glint, Args, Handle) ->
    case execute(Glint, Args) of
        {error, Err} ->
            _pipe = Err,
            _pipe@1 = snag:pretty_print(_pipe),
            gleam@io:println(_pipe@1);

        {ok, {help, Help}} ->
            gleam@io:println(Help);

        {ok, {out, Out}} ->
            Handle(Out),
            nil
    end.

-spec run(glint(any()), list(binary())) -> nil.
run(Glint, Args) ->
    run_and_handle(Glint, Args, gleam@function:constant(nil)).

-spec add_command_from_stub(glint(JJN), stub(JJN)) -> glint(JJN).
add_command_from_stub(Glint, Stub) ->
    add(
        Glint,
        erlang:element(2, Stub),
        begin
            _pipe = command(erlang:element(3, Stub)),
            _pipe@1 = flags(_pipe, erlang:element(4, Stub)),
            description(_pipe@1, erlang:element(5, Stub))
        end
    ).

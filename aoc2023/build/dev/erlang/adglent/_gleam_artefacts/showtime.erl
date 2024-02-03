-module(showtime).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function]).

-export([main/0]).

-spec mk_runner(
    fun((gleam@option:option(list(binary())), list(binary()), showtime@internal@common@cli:capture()) -> NYW),
    glint:command_input()
) -> NYW.
mk_runner(Func, Command) ->
    _assert_subject = begin
        _pipe = erlang:element(3, Command),
        _pipe@1 = glint@flag:get_strings(_pipe, <<"modules"/utf8>>),
        gleam@result:map(_pipe@1, fun(Modules) -> case Modules of
                    [] ->
                        none;

                    Modules@1 ->
                        {some, Modules@1}
                end end)
    end,
    {ok, Module_list} = case _assert_subject of
        {ok, _} -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail,
                        module => <<"showtime"/utf8>>,
                        function => <<"mk_runner"/utf8>>,
                        line => 91})
    end,
    _assert_subject@1 = begin
        _pipe@2 = erlang:element(3, Command),
        glint@flag:get_strings(_pipe@2, <<"ignore"/utf8>>)
    end,
    {ok, Ignore_tags} = case _assert_subject@1 of
        {ok, _} -> _assert_subject@1;
        _assert_fail@1 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail@1,
                        module => <<"showtime"/utf8>>,
                        function => <<"mk_runner"/utf8>>,
                        line => 100})
    end,
    _assert_subject@2 = begin
        _pipe@3 = erlang:element(3, Command),
        _pipe@4 = glint@flag:get_string(_pipe@3, <<"capture"/utf8>>),
        _pipe@5 = gleam@result:map(
            _pipe@4,
            fun(Arg) -> gleam@string:lowercase(Arg) end
        ),
        gleam@result:map(_pipe@5, fun(Arg@1) -> case Arg@1 of
                    <<"no"/utf8>> ->
                        no;

                    <<"yes"/utf8>> ->
                        yes;

                    <<"mixed"/utf8>> ->
                        mixed
                end end)
    end,
    {ok, Capture_output} = case _assert_subject@2 of
        {ok, _} -> _assert_subject@2;
        _assert_fail@2 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail@2,
                        module => <<"showtime"/utf8>>,
                        function => <<"mk_runner"/utf8>>,
                        line => 104})
    end,
    Func(Module_list, Ignore_tags, Capture_output).

-spec start_with_args(
    list(binary()),
    fun((gleam@option:option(list(binary())), list(binary()), showtime@internal@common@cli:capture()) -> any())
) -> nil.
start_with_args(Args, Func) ->
    Modules_flag = begin
        _pipe = glint@flag:string_list(),
        _pipe@1 = glint@flag:default(_pipe, []),
        glint@flag:description(
            _pipe@1,
            <<"Run only tests in the modules in this list"/utf8>>
        )
    end,
    Ignore_flag = begin
        _pipe@2 = glint@flag:string_list(),
        _pipe@3 = glint@flag:default(_pipe@2, []),
        glint@flag:description(
            _pipe@3,
            <<"Ignore tests that are have tags matching a tag in this list"/utf8>>
        )
    end,
    Capture_flag = begin
        _pipe@4 = glint@flag:string(),
        _pipe@5 = glint@flag:default(_pipe@4, <<"no"/utf8>>),
        _pipe@6 = glint@flag:constraint(
            _pipe@5,
            glint@flag@constraint:one_of(
                [<<"yes"/utf8>>, <<"no"/utf8>>, <<"mixed"/utf8>>]
            )
        ),
        glint@flag:description(
            _pipe@6,
            <<"Capture output: no (default) - output when tests are run, yes - output is captured and shown in report, mixed - output when run and in report"/utf8>>
        )
    end,
    _pipe@7 = glint:new(),
    _pipe@12 = glint:add(
        _pipe@7,
        [],
        begin
            _pipe@8 = glint:command(
                fun(_capture) -> mk_runner(Func, _capture) end
            ),
            _pipe@9 = glint:flag(_pipe@8, <<"modules"/utf8>>, Modules_flag),
            _pipe@10 = glint:flag(_pipe@9, <<"ignore"/utf8>>, Ignore_flag),
            _pipe@11 = glint:flag(_pipe@10, <<"capture"/utf8>>, Capture_flag),
            glint:description(_pipe@11, <<"Runs test"/utf8>>)
        end
    ),
    _pipe@13 = glint:with_pretty_help(_pipe@12, glint:default_pretty_help()),
    glint:run(_pipe@13, Args).

-spec main() -> nil.
main() ->
    start_with_args(
        gleam@erlang:start_arguments(),
        fun(Module_list, Ignore_tags, Capture) ->
            Test_event_handler = showtime@internal@erlang@event_handler:start(),
            Test_module_handler = showtime@internal@erlang@module_handler:start(
                Test_event_handler,
                fun showtime@internal@erlang@discover:collect_test_functions/1,
                fun showtime@internal@erlang@runner:run_test_suite/4,
                Ignore_tags,
                Capture
            ),
            Test_event_handler(start_test_run),
            Modules = showtime@internal@erlang@discover:collect_modules(
                Test_module_handler,
                Module_list
            ),
            Test_event_handler(
                {end_test_run,
                    begin
                        _pipe = Modules,
                        gleam@list:length(_pipe)
                    end}
            ),
            nil
        end
    ).

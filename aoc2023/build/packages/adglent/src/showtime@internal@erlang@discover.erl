-module(showtime@internal@erlang@discover).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function]).

-export([collect_modules/2, collect_test_functions/1]).

-spec get_module_prefix(binary()) -> binary().
get_module_prefix(Path) ->
    Path_without_test = begin
        _pipe = Path,
        gleam@string:replace(_pipe, <<"./test"/utf8>>, <<""/utf8>>)
    end,
    Path_without_leading_slash = case gleam@string:starts_with(
        Path_without_test,
        <<"/"/utf8>>
    ) of
        true ->
            gleam@string:drop_left(Path_without_test, 1);

        false ->
            Path_without_test
    end,
    Module_prefix = begin
        _pipe@1 = Path_without_leading_slash,
        gleam@string:replace(_pipe@1, <<"/"/utf8>>, <<"@"/utf8>>)
    end,
    case gleam@string:length(Module_prefix) of
        0 ->
            Module_prefix;

        _ ->
            <<Module_prefix/binary, "@"/utf8>>
    end.

-spec collect_modules_in_folder(
    binary(),
    fun((showtime@internal@common@test_suite:test_module()) -> nil),
    gleam@option:option(list(binary()))
) -> list(showtime@internal@common@test_suite:test_module()).
collect_modules_in_folder(Path, Test_module_handler, Only_modules) ->
    Module_prefix = get_module_prefix(Path),
    _assert_subject = simplifile:read_directory(Path),
    {ok, Files} = case _assert_subject of
        {ok, _} -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail,
                        module => <<"showtime/internal/erlang/discover"/utf8>>,
                        function => <<"collect_modules_in_folder"/utf8>>,
                        line => 40})
    end,
    Test_modules_in_folder = begin
        _pipe = Files,
        _pipe@1 = gleam@list:filter(
            _pipe,
            fun(_capture) ->
                gleam@string:ends_with(_capture, <<"_test.gleam"/utf8>>)
            end
        ),
        gleam@list:filter_map(
            _pipe@1,
            fun(Test_module_file) ->
                Module_name = <<Module_prefix/binary,
                    (begin
                        _pipe@2 = Test_module_file,
                        gleam@string:replace(
                            _pipe@2,
                            <<".gleam"/utf8>>,
                            <<""/utf8>>
                        )
                    end)/binary>>,
                case Only_modules of
                    {some, Only_modules_list} ->
                        Module_in_list = begin
                            _pipe@3 = Only_modules_list,
                            gleam@list:any(
                                _pipe@3,
                                fun(Only_module_name) ->
                                    Only_module_name =:= begin
                                        _pipe@4 = Module_name,
                                        gleam@string:replace(
                                            _pipe@4,
                                            <<"@"/utf8>>,
                                            <<"/"/utf8>>
                                        )
                                    end
                                end
                            )
                        end,
                        case Module_in_list of
                            true ->
                                Test_module = {test_module,
                                    Module_name,
                                    {some, Test_module_file}},
                                Test_module_handler(Test_module),
                                {ok, Test_module};

                            false ->
                                {error, nil}
                        end;

                    none ->
                        Test_module@1 = {test_module,
                            Module_name,
                            {some, Test_module_file}},
                        Test_module_handler(Test_module@1),
                        {ok, Test_module@1}
                end
            end
        )
    end,
    Test_modules_in_subfolders = begin
        _pipe@5 = Files,
        _pipe@6 = gleam@list:map(
            _pipe@5,
            fun(Filename) ->
                <<<<Path/binary, "/"/utf8>>/binary, Filename/binary>>
            end
        ),
        _pipe@7 = gleam@list:filter(
            _pipe@6,
            fun(File) -> simplifile:is_directory(File) end
        ),
        gleam@list:fold(
            _pipe@7,
            [],
            fun(Modules, Subfolder) -> _pipe@8 = Modules,
                gleam@list:append(
                    _pipe@8,
                    collect_modules_in_folder(
                        Subfolder,
                        Test_module_handler,
                        Only_modules
                    )
                ) end
        )
    end,
    _pipe@9 = Test_modules_in_folder,
    gleam@list:append(_pipe@9, Test_modules_in_subfolders).

-spec collect_modules(
    fun((showtime@internal@common@test_suite:test_module()) -> nil),
    gleam@option:option(list(binary()))
) -> list(showtime@internal@common@test_suite:test_module()).
collect_modules(Test_module_handler, Only_modules) ->
    collect_modules_in_folder(
        <<"./test"/utf8>>,
        Test_module_handler,
        Only_modules
    ).

-spec collect_test_functions(showtime@internal@common@test_suite:test_module()) -> showtime@internal@common@test_suite:test_suite().
collect_test_functions(Module) ->
    Test_functions = begin
        _pipe = erlang:apply(
            erlang:binary_to_atom(erlang:element(2, Module)),
            erlang:binary_to_atom(<<"module_info"/utf8>>),
            [gleam@dynamic:from(erlang:binary_to_atom(<<"exports"/utf8>>))]
        ),
        gleam@dynamic:unsafe_coerce(_pipe)
    end,
    Test_functions_filtered = begin
        _pipe@1 = Test_functions,
        _pipe@3 = gleam@list:map(
            _pipe@1,
            fun(Entry) ->
                {Name, Arity} = case Entry of
                    {_, _} -> Entry;
                    _assert_fail ->
                        erlang:error(#{gleam_error => let_assert,
                                    message => <<"Assertion pattern match failed"/utf8>>,
                                    value => _assert_fail,
                                    module => <<"showtime/internal/erlang/discover"/utf8>>,
                                    function => <<"collect_test_functions"/utf8>>,
                                    line => 131})
                end,
                {begin
                        _pipe@2 = Name,
                        erlang:atom_to_binary(_pipe@2)
                    end,
                    Arity}
            end
        ),
        _pipe@4 = gleam@list:filter_map(
            _pipe@3,
            fun(Entry@1) ->
                {Name@1, Arity@1} = case Entry@1 of
                    {_, _} -> Entry@1;
                    _assert_fail@1 ->
                        erlang:error(#{gleam_error => let_assert,
                                    message => <<"Assertion pattern match failed"/utf8>>,
                                    value => _assert_fail@1,
                                    module => <<"showtime/internal/erlang/discover"/utf8>>,
                                    function => <<"collect_test_functions"/utf8>>,
                                    line => 139})
                end,
                case gleam@string:ends_with(Name@1, <<"_test"/utf8>>) of
                    true ->
                        case Arity@1 of
                            0 ->
                                {ok, Name@1};

                            _ ->
                                gleam@io:println(
                                    <<<<<<<<"WARNING: function \""/utf8,
                                                    Name@1/binary>>/binary,
                                                "\" has arity: "/utf8>>/binary,
                                            (gleam@int:to_string(Arity@1))/binary>>/binary,
                                        " - cannot be used as test (needs to be 0)"/utf8>>
                                ),
                                {error, <<"Wrong arity"/utf8>>}
                        end;

                    false ->
                        {error, <<"Non matching name"/utf8>>}
                end
            end
        ),
        _pipe@5 = gleam@list:filter(
            _pipe@4,
            fun(_capture) ->
                gleam@string:ends_with(_capture, <<"_test"/utf8>>)
            end
        ),
        gleam@list:map(
            _pipe@5,
            fun(Function_name) -> {test_function, Function_name} end
        )
    end,
    {test_suite, Module, Test_functions_filtered}.

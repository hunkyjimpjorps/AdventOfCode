-module(adglent@init).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function]).

-export([main/0]).

-spec main() -> {ok, binary()} | {error, binary()}.
main() ->
    Year = priv@prompt:value(<<"Year"/utf8>>, <<"2023"/utf8>>, false),
    Session = priv@prompt:value(<<"Session Cookie"/utf8>>, <<""/utf8>>, false),
    Use_showtime = priv@prompt:confirm(<<"Use showtime"/utf8>>, false),
    Aoc_toml_file = <<"aoc.toml"/utf8>>,
    Overwrite = case simplifile:create_file(Aoc_toml_file) of
        {ok, _} ->
            true;

        {error, eexist} ->
            priv@prompt:confirm(<<"aoc.toml exits - overwrite"/utf8>>, false);

        _ ->
            erlang:error(#{gleam_error => panic,
                    message => <<"Could not create aoc.toml"/utf8>>,
                    module => <<"adglent/init"/utf8>>,
                    function => <<"main"/utf8>>,
                    line => 29})
    end,
    _pipe@3 = case Overwrite of
        true ->
            _pipe@1 = priv@template:render(
                <<"
version = {{ version }}
year = \"{{ year }}\"
session = \"{{ session }}\"
showtime = {{ showtime }}
"/utf8>>,
                [{<<"version"/utf8>>, <<"2"/utf8>>},
                    {<<"year"/utf8>>, Year},
                    {<<"session"/utf8>>, Session},
                    {<<"showtime"/utf8>>,
                        begin
                            _pipe = gleam@bool:to_string(Use_showtime),
                            gleam@string:lowercase(_pipe)
                        end}]
            ),
            _pipe@2 = simplifile:write(Aoc_toml_file, _pipe@1),
            priv@errors:map_messages(
                _pipe@2,
                <<"aoc.toml - written"/utf8>>,
                <<"Error when writing aoc.toml"/utf8>>
            );

        false ->
            {ok, <<"aoc.toml - skipped"/utf8>>}
    end,
    priv@errors:print_result(_pipe@3),
    Gleam_toml = begin
        _pipe@4 = simplifile:read(<<"gleam.toml"/utf8>>),
        _pipe@5 = priv@errors:map_error(
            _pipe@4,
            <<"Could not read gleam.toml"/utf8>>
        ),
        _pipe@6 = priv@errors:print_error(_pipe@5),
        priv@errors:assert_ok(_pipe@6)
    end,
    Name = begin
        _pipe@7 = priv@toml:get_string(Gleam_toml, [<<"name"/utf8>>]),
        _pipe@8 = priv@errors:map_error(
            _pipe@7,
            <<"Could not read \"name\" from gleam.toml"/utf8>>
        ),
        _pipe@9 = priv@errors:print_error(_pipe@8),
        priv@errors:assert_ok(_pipe@9)
    end,
    Test_main_file = <<<<"test/"/utf8, Name/binary>>/binary,
        "_test.gleam"/utf8>>,
    _pipe@12 = case Use_showtime of
        true ->
            _pipe@10 = priv@template:render(
                <<"
import showtime

pub fn main() {
  showtime.main()
}
"/utf8>>,
                []
            ),
            _pipe@11 = simplifile:write(Test_main_file, _pipe@10),
            priv@errors:map_messages(
                _pipe@11,
                <<"Wrote "/utf8, Test_main_file/binary>>,
                <<"Could not write to "/utf8, Test_main_file/binary>>
            );

        false ->
            {ok, <<"Using existing (gleeunit) "/utf8, Test_main_file/binary>>}
    end,
    _pipe@13 = priv@errors:print_result(_pipe@12),
    priv@errors:assert_ok(_pipe@13),
    _pipe@17 = case simplifile:is_file(<<".gitignore"/utf8>>) of
        true ->
            gleam@result:'try'(
                begin
                    _pipe@14 = simplifile:read(<<".gitignore"/utf8>>),
                    gleam@result:map_error(
                        _pipe@14,
                        fun(Err) ->
                            <<"Could not read .gitignore: "/utf8,
                                (gleam@string:inspect(Err))/binary>>
                        end
                    )
                end,
                fun(Gitignore) ->
                    Aoc_toml_ignored = begin
                        _pipe@15 = gleam@string:split(Gitignore, <<"\n"/utf8>>),
                        gleam@list:find(
                            _pipe@15,
                            fun(Line) -> Line =:= <<"aoc.toml"/utf8>> end
                        )
                    end,
                    case Aoc_toml_ignored of
                        {error, _} ->
                            _pipe@16 = simplifile:append(
                                <<".gitignore"/utf8>>,
                                <<"\naoc.toml"/utf8>>
                            ),
                            priv@errors:map_messages(
                                _pipe@16,
                                <<".gitignore written"/utf8>>,
                                <<"Error when writing .gitignore"/utf8>>
                            );

                        {ok, _} ->
                            {ok,
                                <<".gitignore - skipped (already configured)"/utf8>>}
                    end
                end
            );

        false ->
            {error, <<"Could not find .gitignore"/utf8>>}
    end,
    priv@errors:print_result(_pipe@17).

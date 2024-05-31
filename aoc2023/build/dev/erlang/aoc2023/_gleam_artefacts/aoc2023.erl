-module(aoc2023).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch]).

-export([main/0]).

-spec main() -> bitstring().
main() ->
    Trim = 8,
    _assert_subject = gleam_stdlib:identity(<<"abcdefgh
abcdefgh"/utf8>>),
    <<_:Trim/binary, "\n"/utf8, Rest/binary>> = case _assert_subject of
        <<_:Trim/binary, "\n"/utf8, _/binary>> -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail,
                        module => <<"aoc2023"/utf8>>,
                        function => <<"main"/utf8>>,
                        line => 9})
    end,
    gleam@io:debug(Rest).

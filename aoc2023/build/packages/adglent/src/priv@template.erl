-module(priv@template).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function]).

-export([render/2]).

-spec render(binary(), list({binary(), binary()})) -> binary().
render(Template, Substitutions) ->
    <<(begin
            _pipe = Substitutions,
            _pipe@2 = gleam@list:fold(
                _pipe,
                Template,
                fun(Template@1, Substitution) ->
                    {Name, Value} = Substitution,
                    _pipe@1 = Template@1,
                    gleam@string:replace(
                        _pipe@1,
                        <<<<"{{ "/utf8, Name/binary>>/binary, " }}"/utf8>>,
                        Value
                    )
                end
            ),
            gleam@string:trim(_pipe@2)
        end)/binary,
        "\n"/utf8>>.

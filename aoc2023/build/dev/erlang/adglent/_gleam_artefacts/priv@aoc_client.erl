-module(priv@aoc_client).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch]).

-export([get_input/3]).

-spec get_input(binary(), binary(), binary()) -> {ok, binary()} |
    {error, binary()}.
get_input(Year, Day, Session) ->
    Url = <<<<<<<<"https://adventofcode.com/"/utf8, Year/binary>>/binary,
                "/day/"/utf8>>/binary,
            Day/binary>>/binary,
        "/input"/utf8>>,
    gleam@result:'try'(
        begin
            _pipe = gleam@http@request:to(Url),
            gleam@result:map_error(
                _pipe,
                fun(Error) ->
                    <<<<<<"Could not create request for \""/utf8, Url/binary>>/binary,
                            "\": "/utf8>>/binary,
                        (gleam@string:inspect(Error))/binary>>
                end
            )
        end,
        fun(Request) ->
            gleam@result:'try'(
                begin
                    _pipe@1 = Request,
                    _pipe@2 = gleam@http@request:prepend_header(
                        _pipe@1,
                        <<"Accept"/utf8>>,
                        <<"application/json"/utf8>>
                    ),
                    _pipe@3 = gleam@http@request:prepend_header(
                        _pipe@2,
                        <<"Cookie"/utf8>>,
                        <<<<"session="/utf8, Session/binary>>/binary, ";"/utf8>>
                    ),
                    _pipe@4 = gleam@httpc:send(_pipe@3),
                    gleam@result:map_error(
                        _pipe@4,
                        fun(Error@1) ->
                            <<<<<<"Error when requesting \""/utf8, Url/binary>>/binary,
                                    "\": "/utf8>>/binary,
                                (gleam@string:inspect(Error@1))/binary>>
                        end
                    )
                end,
                fun(Response) -> case erlang:element(2, Response) of
                        Status when (Status >= 200) andalso (Status < 300) ->
                            {ok, erlang:element(4, Response)};

                        Status@1 ->
                            {error,
                                <<<<(gleam@int:to_string(Status@1))/binary,
                                        " - "/utf8>>/binary,
                                    (erlang:element(4, Response))/binary>>}
                    end end
            )
        end
    ).

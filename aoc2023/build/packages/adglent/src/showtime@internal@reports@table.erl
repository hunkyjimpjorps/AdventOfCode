-module(showtime@internal@reports@table).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function]).

-export([to_string/1, align_table/1]).
-export_type([content/0, col/0, table/0]).

-type content() :: {content, binary()} | {styled_content, binary()}.

-type col() :: {align_right, content(), integer()} |
    {align_left, content(), integer()} |
    {align_right_overflow, content(), integer()} |
    {align_left_overflow, content(), integer()} |
    {separator, binary()} |
    {aligned, binary()}.

-type table() :: {table, gleam@option:option(binary()), list(list(col()))}.

-spec to_string(table()) -> binary().
to_string(Table) ->
    Rows = begin
        _pipe = erlang:element(3, Table),
        _pipe@3 = gleam@list:map(_pipe, fun(Row) -> _pipe@1 = Row,
                _pipe@2 = gleam@list:filter_map(_pipe@1, fun(Col) -> case Col of
                            {separator, Char} ->
                                {ok, Char};

                            {aligned, Content} ->
                                {ok, Content};

                            _ ->
                                {error, nil}
                        end end),
                gleam@string:join(_pipe@2, <<""/utf8>>) end),
        gleam@string:join(_pipe@3, <<"\n"/utf8>>)
    end,
    Header@1 = begin
        _pipe@4 = erlang:element(2, Table),
        _pipe@5 = gleam@option:map(
            _pipe@4,
            fun(Header) -> <<Header/binary, "\n"/utf8>> end
        ),
        gleam@option:unwrap(_pipe@5, <<""/utf8>>)
    end,
    <<Header@1/binary, Rows/binary>>.

-spec pad_left(binary(), integer(), binary()) -> binary().
pad_left(Str, Num, Char) ->
    Padding = begin
        _pipe = gleam@list:repeat(Char, Num),
        gleam@string:join(_pipe, <<""/utf8>>)
    end,
    <<Padding/binary, Str/binary>>.

-spec pad_right(binary(), integer(), binary()) -> binary().
pad_right(Str, Num, Char) ->
    Padding = begin
        _pipe = gleam@list:repeat(Char, Num),
        gleam@string:join(_pipe, <<""/utf8>>)
    end,
    <<Str/binary, Padding/binary>>.

-spec align_table(table()) -> table().
align_table(Table) ->
    Cols = begin
        _pipe = erlang:element(3, Table),
        gleam@list:transpose(_pipe)
    end,
    Col_width = begin
        _pipe@1 = Cols,
        gleam@list:map(_pipe@1, fun(Col) -> _pipe@2 = Col,
                _pipe@3 = gleam@list:map(
                    _pipe@2,
                    fun(Content) -> case Content of
                            {align_right, {content, Unstyled}, _} ->
                                Unstyled;

                            {align_right, {styled_content, Styled}, _} ->
                                showtime@internal@reports@styles:strip_style(
                                    Styled
                                );

                            {align_left, {content, Unstyled@1}, _} ->
                                Unstyled@1;

                            {align_left, {styled_content, Styled@1}, _} ->
                                showtime@internal@reports@styles:strip_style(
                                    Styled@1
                                );

                            {align_left_overflow, _, _} ->
                                <<""/utf8>>;

                            {align_right_overflow, _, _} ->
                                <<""/utf8>>;

                            {separator, Char} ->
                                Char;

                            {aligned, Content@1} ->
                                Content@1
                        end end
                ),
                gleam@list:fold(
                    _pipe@3,
                    0,
                    fun(Max, Str) ->
                        gleam@int:max(Max, gleam@string:length(Str))
                    end
                ) end)
    end,
    Aligned_col = begin
        _pipe@4 = Cols,
        _pipe@5 = gleam@list:zip(_pipe@4, Col_width),
        gleam@list:map(
            _pipe@5,
            fun(Col_and_width) ->
                {Col@1, Width} = Col_and_width,
                _pipe@6 = Col@1,
                gleam@list:map(_pipe@6, fun(Content@2) -> case Content@2 of
                            {align_right, {content, Unstyled@2}, Margin} ->
                                {aligned,
                                    pad_left(
                                        Unstyled@2,
                                        (Width + Margin) - gleam@string:length(
                                            Unstyled@2
                                        ),
                                        <<" "/utf8>>
                                    )};

                            {align_right, {styled_content, Styled@2}, Margin@1} ->
                                {aligned,
                                    pad_left(
                                        Styled@2,
                                        (Width + Margin@1) - gleam@string:length(
                                            showtime@internal@reports@styles:strip_style(
                                                Styled@2
                                            )
                                        ),
                                        <<" "/utf8>>
                                    )};

                            {align_right_overflow,
                                {content, Unstyled@3},
                                Margin@2} ->
                                {aligned,
                                    pad_left(
                                        Unstyled@3,
                                        (Width + Margin@2) - gleam@string:length(
                                            Unstyled@3
                                        ),
                                        <<" "/utf8>>
                                    )};

                            {align_right_overflow,
                                {styled_content, Styled@3},
                                Margin@3} ->
                                {aligned,
                                    pad_left(
                                        Styled@3,
                                        (Width + Margin@3) - gleam@string:length(
                                            showtime@internal@reports@styles:strip_style(
                                                Styled@3
                                            )
                                        ),
                                        <<" "/utf8>>
                                    )};

                            {align_left, {content, Unstyled@4}, Margin@4} ->
                                {aligned,
                                    pad_right(
                                        Unstyled@4,
                                        (Width + Margin@4) - gleam@string:length(
                                            Unstyled@4
                                        ),
                                        <<" "/utf8>>
                                    )};

                            {align_left, {styled_content, Styled@4}, Margin@5} ->
                                {aligned,
                                    pad_right(
                                        Styled@4,
                                        (Width + Margin@5) - gleam@string:length(
                                            showtime@internal@reports@styles:strip_style(
                                                Styled@4
                                            )
                                        ),
                                        <<" "/utf8>>
                                    )};

                            {align_left_overflow,
                                {content, Unstyled@5},
                                Margin@6} ->
                                {aligned,
                                    pad_right(
                                        Unstyled@5,
                                        (Width + Margin@6) - gleam@string:length(
                                            Unstyled@5
                                        ),
                                        <<" "/utf8>>
                                    )};

                            {align_left_overflow,
                                {styled_content, Styled@5},
                                Margin@7} ->
                                {aligned,
                                    pad_right(
                                        Styled@5,
                                        (Width + Margin@7) - gleam@string:length(
                                            showtime@internal@reports@styles:strip_style(
                                                Styled@5
                                            )
                                        ),
                                        <<" "/utf8>>
                                    )};

                            {separator, Char@1} ->
                                {separator, Char@1};

                            {aligned, Content@3} ->
                                {aligned, Content@3}
                        end end)
            end
        )
    end,
    Aligned_rows = begin
        _pipe@7 = Aligned_col,
        gleam@list:transpose(_pipe@7)
    end,
    erlang:setelement(3, Table, Aligned_rows).

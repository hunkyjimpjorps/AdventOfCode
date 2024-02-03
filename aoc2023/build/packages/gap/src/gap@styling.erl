-module(gap@styling).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function]).

-export([from_comparison/1, highlight/4, serialize/2, first_highlight_default/1, second_highlight_default/1, no_highlight/1, mk_generic_serializer/2, to_styled_comparison/1]).
-export_type([part/1, highlighters/0, styling/1]).

-type part(FRE) :: {part, binary(), list(FRE), fun((binary()) -> binary())} |
    {all, binary()}.

-type highlighters() :: {highlighters,
        fun((binary()) -> binary()),
        fun((binary()) -> binary()),
        fun((binary()) -> binary())}.

-opaque styling(FRF) :: {styling,
        gap@comparison:comparison(FRF),
        gleam@option:option(fun((part(FRF)) -> binary())),
        gleam@option:option(highlighters())}.

-spec from_comparison(gap@comparison:comparison(FRI)) -> styling(FRI).
from_comparison(Comparison) ->
    {styling, Comparison, none, none}.

-spec highlight(
    styling(FRL),
    fun((binary()) -> binary()),
    fun((binary()) -> binary()),
    fun((binary()) -> binary())
) -> styling(FRL).
highlight(Styling, First, Second, Matching) ->
    erlang:setelement(
        4,
        Styling,
        {some, {highlighters, First, Second, Matching}}
    ).

-spec serialize(styling(FRO), fun((part(FRO)) -> binary())) -> styling(FRO).
serialize(Styling, Serializer) ->
    erlang:setelement(3, Styling, {some, Serializer}).

-spec first_highlight_default(binary()) -> binary().
first_highlight_default(String) ->
    case String of
        <<" "/utf8>> ->
            _pipe = String,
            _pipe@1 = gleam_community@ansi:underline(_pipe),
            _pipe@2 = gleam_community@ansi:bold(_pipe@1),
            gleam_community@ansi:green(_pipe@2);

        _ ->
            _pipe@3 = String,
            _pipe@4 = gleam_community@ansi:green(_pipe@3),
            gleam_community@ansi:bold(_pipe@4)
    end.

-spec second_highlight_default(binary()) -> binary().
second_highlight_default(String) ->
    case String of
        <<" "/utf8>> ->
            _pipe = String,
            _pipe@1 = gleam_community@ansi:underline(_pipe),
            _pipe@2 = gleam_community@ansi:bold(_pipe@1),
            gleam_community@ansi:red(_pipe@2);

        _ ->
            _pipe@3 = String,
            _pipe@4 = gleam_community@ansi:red(_pipe@3),
            gleam_community@ansi:bold(_pipe@4)
    end.

-spec no_highlight(binary()) -> binary().
no_highlight(String) ->
    String.

-spec string_serializer(part(binary())) -> binary().
string_serializer(Part) ->
    case Part of
        {part, Acc, Sequence, Highlight} ->
            <<Acc/binary,
                (begin
                    _pipe = Sequence,
                    _pipe@1 = gleam@list:map(_pipe, Highlight),
                    gleam@string:join(_pipe@1, <<""/utf8>>)
                end)/binary>>;

        {all, String} ->
            String
    end.

-spec mk_generic_serializer(binary(), fun((binary()) -> binary())) -> fun((part(any())) -> binary()).
mk_generic_serializer(Separator, Around) ->
    fun(Part) -> case Part of
            {part, Acc, Sequence, Highlight} ->
                Segment_separator = case Acc of
                    <<""/utf8>> ->
                        <<""/utf8>>;

                    _ ->
                        Separator
                end,
                <<<<Acc/binary, Segment_separator/binary>>/binary,
                    (begin
                        _pipe = Sequence,
                        _pipe@1 = gleam@list:map(
                            _pipe,
                            fun gleam@string:inspect/1
                        ),
                        _pipe@2 = gleam@list:map(_pipe@1, Highlight),
                        gleam@string:join(_pipe@2, Separator)
                    end)/binary>>;

            {all, String} ->
                Around(String)
        end end.

-spec generic_serializer(part(any())) -> binary().
generic_serializer(Part) ->
    (mk_generic_serializer(
        <<", "/utf8>>,
        fun(All) -> <<<<"["/utf8, All/binary>>/binary, "]"/utf8>> end
    ))(Part).

-spec to_strings(
    list(gap@comparison:match(list(FRY))),
    list(gap@comparison:match(list(FRY))),
    fun((part(FRY)) -> binary()),
    fun((binary()) -> binary()),
    fun((binary()) -> binary()),
    fun((binary()) -> binary())
) -> gap@styled_comparison:styled_comparison().
to_strings(
    First,
    Second,
    Serializer,
    First_highlight,
    Second_highlight,
    No_highlight
) ->
    First_styled = begin
        _pipe = First,
        gleam@list:fold(_pipe, <<""/utf8>>, fun(Str, Match) -> case Match of
                    {match, Item} ->
                        Serializer({part, Str, Item, No_highlight});

                    {no_match, Item@1} ->
                        Serializer({part, Str, Item@1, First_highlight})
                end end)
    end,
    Second_styled = begin
        _pipe@1 = Second,
        gleam@list:fold(
            _pipe@1,
            <<""/utf8>>,
            fun(Str@1, Match@1) -> case Match@1 of
                    {match, Item@2} ->
                        Serializer({part, Str@1, Item@2, No_highlight});

                    {no_match, Item@3} ->
                        Serializer({part, Str@1, Item@3, Second_highlight})
                end end
        )
    end,
    {styled_comparison,
        Serializer({all, First_styled}),
        Serializer({all, Second_styled})}.

-spec to_styled_comparison(styling(any())) -> gap@styled_comparison:styled_comparison().
to_styled_comparison(Styling) ->
    Highlight = begin
        _pipe = erlang:element(4, Styling),
        gleam@option:unwrap(
            _pipe,
            {highlighters,
                fun first_highlight_default/1,
                fun second_highlight_default/1,
                fun no_highlight/1}
        )
    end,
    case erlang:element(2, Styling) of
        {string_comparison, First, Second} ->
            to_strings(
                First,
                Second,
                fun string_serializer/1,
                erlang:element(2, Highlight),
                erlang:element(3, Highlight),
                erlang:element(4, Highlight)
            );

        {list_comparison, First@1, Second@1} ->
            to_strings(
                First@1,
                Second@1,
                gleam@option:unwrap(
                    erlang:element(3, Styling),
                    fun generic_serializer/1
                ),
                erlang:element(2, Highlight),
                erlang:element(3, Highlight),
                erlang:element(4, Highlight)
            )
    end.

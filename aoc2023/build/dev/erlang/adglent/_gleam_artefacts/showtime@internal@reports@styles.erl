-module(showtime@internal@reports@styles).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch]).

-export([not_style/1, module_style/1, heading_style/1, stacktrace_style/1, failed_style/1, error_style/1, got_highlight/1, passed_style/1, expected_highlight/1, ignored_style/1, function_style/1, strip_style/1]).

-spec not_style(binary()) -> binary().
not_style(Text) ->
    gleam_community@ansi:bold(Text).

-spec module_style(binary()) -> binary().
module_style(Text) ->
    gleam_community@ansi:cyan(Text).

-spec heading_style(binary()) -> binary().
heading_style(Text) ->
    gleam_community@ansi:cyan(Text).

-spec stacktrace_style(binary()) -> binary().
stacktrace_style(Text) ->
    Text.

-spec bold_red(binary()) -> binary().
bold_red(Text) ->
    gleam_community@ansi:bold(gleam_community@ansi:red(Text)).

-spec failed_style(binary()) -> binary().
failed_style(Text) ->
    bold_red(Text).

-spec error_style(binary()) -> binary().
error_style(Text) ->
    bold_red(Text).

-spec got_highlight(binary()) -> binary().
got_highlight(Text) ->
    bold_red(Text).

-spec bold_green(binary()) -> binary().
bold_green(Text) ->
    gleam_community@ansi:bold(gleam_community@ansi:green(Text)).

-spec passed_style(binary()) -> binary().
passed_style(Text) ->
    bold_green(Text).

-spec expected_highlight(binary()) -> binary().
expected_highlight(Text) ->
    bold_green(Text).

-spec bold_yellow(binary()) -> binary().
bold_yellow(Text) ->
    gleam_community@ansi:bold(gleam_community@ansi:yellow(Text)).

-spec ignored_style(binary()) -> binary().
ignored_style(Text) ->
    bold_yellow(Text).

-spec bold_cyan(binary()) -> binary().
bold_cyan(Text) ->
    gleam_community@ansi:bold(gleam_community@ansi:cyan(Text)).

-spec function_style(binary()) -> binary().
function_style(Text) ->
    bold_cyan(Text).

-spec strip_style(binary()) -> binary().
strip_style(Text) ->
    {New_text, _} = begin
        _pipe = Text,
        _pipe@1 = gleam@string:to_graphemes(_pipe),
        gleam@list:fold(
            _pipe@1,
            {<<""/utf8>>, false},
            fun(Acc, Char) ->
                {Str, Removing} = Acc,
                Bit_char = gleam_stdlib:identity(Char),
                case {Bit_char, Removing} of
                    {<<16#1b>>, _} ->
                        {Str, true};

                    {<<16#6d>>, true} ->
                        {Str, false};

                    {_, true} ->
                        {Str, true};

                    {_, false} ->
                        {<<Str/binary, Char/binary>>, false}
                end
            end
        )
    end,
    New_text.

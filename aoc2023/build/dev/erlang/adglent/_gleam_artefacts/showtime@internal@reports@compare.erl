-module(showtime@internal@reports@compare).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch]).

-export([compare/2]).

-spec compare(gleam@dynamic:dynamic_(), gleam@dynamic:dynamic_()) -> {binary(),
    binary()}.
compare(Expected, Got) ->
    Expected_as_list = begin
        _pipe = Expected,
        (gleam@dynamic:list(fun gleam@dynamic:dynamic/1))(_pipe)
    end,
    Got_as_list = begin
        _pipe@1 = Got,
        (gleam@dynamic:list(fun gleam@dynamic:dynamic/1))(_pipe@1)
    end,
    Expected_as_string = begin
        _pipe@2 = Expected,
        gleam@dynamic:string(_pipe@2)
    end,
    Got_as_string = begin
        _pipe@3 = Got,
        gleam@dynamic:string(_pipe@3)
    end,
    case {Expected_as_list, Got_as_list, Expected_as_string, Got_as_string} of
        {{ok, Expected_list}, {ok, Got_list}, _, _} ->
            Comparison = begin
                _pipe@4 = gap:compare_lists(Expected_list, Got_list),
                _pipe@5 = gap@styling:from_comparison(_pipe@4),
                _pipe@6 = gap@styling:highlight(
                    _pipe@5,
                    fun showtime@internal@reports@styles:expected_highlight/1,
                    fun showtime@internal@reports@styles:got_highlight/1,
                    fun(Item) -> Item end
                ),
                gap@styling:to_styled_comparison(_pipe@6)
            end,
            {erlang:element(2, Comparison), erlang:element(3, Comparison)};

        {_, _, {ok, Expected_string}, {ok, Got_string}} ->
            Comparison@1 = begin
                _pipe@7 = gap:compare_strings(Expected_string, Got_string),
                _pipe@8 = gap@styling:from_comparison(_pipe@7),
                _pipe@9 = gap@styling:highlight(
                    _pipe@8,
                    fun showtime@internal@reports@styles:expected_highlight/1,
                    fun showtime@internal@reports@styles:got_highlight/1,
                    fun(Item@1) -> Item@1 end
                ),
                gap@styling:to_styled_comparison(_pipe@9)
            end,
            {erlang:element(2, Comparison@1), erlang:element(3, Comparison@1)};

        {_, _, _, _} ->
            {showtime@internal@reports@styles:expected_highlight(
                    gleam@string:inspect(Expected)
                ),
                showtime@internal@reports@styles:got_highlight(
                    gleam@string:inspect(Got)
                )}
    end.

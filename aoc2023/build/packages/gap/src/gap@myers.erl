-module(gap@myers).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function]).

-export([difference/2]).
-export_type([edit/1, path/1, status/1]).

-type edit(FUV) :: {eq, list(FUV)} | {del, list(FUV)} | {ins, list(FUV)}.

-type path(FUW) :: {path,
        integer(),
        integer(),
        list(FUW),
        list(FUW),
        list(edit(FUW))}.

-type status(FUX) :: {done, list(edit(FUX))} |
    {next, list(path(FUX))} |
    {cont, path(FUX)}.

-spec compact_reverse(list(edit(FVH)), list(edit(FVH))) -> list(edit(FVH)).
compact_reverse(Edits, Acc) ->
    case {Edits, Acc} of
        {[], Acc@1} ->
            Acc@1;

        {[{eq, Elem} | Rest], [{eq, Result} | Acc_rest]} ->
            compact_reverse(
                Rest,
                [{eq, gleam@list:flatten([Elem, Result])} | Acc_rest]
            );

        {[{del, Elem@1} | Rest@1], [{del, Result@1} | Acc_rest@1]} ->
            compact_reverse(
                Rest@1,
                [{del, gleam@list:flatten([Elem@1, Result@1])} | Acc_rest@1]
            );

        {[{ins, Elem@2} | Rest@2], [{ins, Result@2} | Acc_rest@2]} ->
            compact_reverse(
                Rest@2,
                [{ins, gleam@list:flatten([Elem@2, Result@2])} | Acc_rest@2]
            );

        {[{eq, Elem@3} | Rest@3], Acc@2} ->
            compact_reverse(Rest@3, [{eq, Elem@3} | Acc@2]);

        {[{del, Elem@4} | Rest@4], Acc@3} ->
            compact_reverse(Rest@4, [{del, Elem@4} | Acc@3]);

        {[{ins, Elem@5} | Rest@5], Acc@4} ->
            compact_reverse(Rest@5, [{ins, Elem@5} | Acc@4])
    end.

-spec move_right(path(FWA)) -> path(FWA).
move_right(Path) ->
    case Path of
        {path, X, Y, List1, [Elem | Rest], Edits} ->
            {path, X + 1, Y, List1, Rest, [{ins, [Elem]} | Edits]};

        {path, X@1, Y@1, List1@1, [], Edits@1} ->
            {path, X@1 + 1, Y@1, List1@1, [], Edits@1}
    end.

-spec move_down(path(FWD)) -> path(FWD).
move_down(Path) ->
    case Path of
        {path, X, Y, [Elem | Rest], List2, Edits} ->
            {path, X, Y + 1, Rest, List2, [{del, [Elem]} | Edits]};

        {path, X@1, Y@1, [], List2@1, Edits@1} ->
            {path, X@1, Y@1 + 1, [], List2@1, Edits@1}
    end.

-spec proceed_path(integer(), integer(), list(path(FVU))) -> {path(FVU),
    list(path(FVU))}.
proceed_path(Diag, Limit, Paths) ->
    Neg_limit = - Limit,
    case {Diag, Limit, Paths} of
        {0, 0, [Path]} ->
            {Path, []};

        {Diag@1, _, [Path@1 | _] = Paths@1} when Diag@1 =:= Neg_limit ->
            {move_down(Path@1), Paths@1};

        {Diag@2, Limit@1, [Path@2 | _] = Paths@2} when Diag@2 =:= Limit@1 ->
            {move_right(Path@2), Paths@2};

        {_, _, [Path1, Path2 | Rest]} ->
            case erlang:element(3, Path1) > erlang:element(3, Path2) of
                true ->
                    {move_right(Path1), [Path2 | Rest]};

                false ->
                    {move_down(Path2), [Path2 | Rest]}
            end
    end.

-spec follow_snake(path(FWG)) -> status(FWG).
follow_snake(Path) ->
    case Path of
        {path, X, Y, [Elem1 | Rest1], [Elem2 | Rest2], Edits} when Elem1 =:= Elem2 ->
            follow_snake(
                {path, X + 1, Y + 1, Rest1, Rest2, [{eq, [Elem1]} | Edits]}
            );

        {path, _, _, [], [], Edits@1} ->
            {done, Edits@1};

        _ ->
            {cont, Path}
    end.

-spec each_diagonal(integer(), integer(), list(path(FVO)), list(path(FVO))) -> status(FVO).
each_diagonal(Diag, Limit, Paths, Next_paths) ->
    case Diag > Limit of
        true ->
            {next, gleam@list:reverse(Next_paths)};

        false ->
            {Path, Rest} = proceed_path(Diag, Limit, Paths),
            case follow_snake(Path) of
                {cont, Path@1} ->
                    each_diagonal(Diag + 2, Limit, Rest, [Path@1 | Next_paths]);

                Other ->
                    Other
            end
    end.

-spec find_script(integer(), integer(), list(path(FVD))) -> list(edit(FVD)).
find_script(Envelope, Max, Paths) ->
    case Envelope > Max of
        true ->
            [];

        false ->
            case each_diagonal(- Envelope, Envelope, Paths, []) of
                {done, Edits} ->
                    compact_reverse(Edits, []);

                {next, Paths@1} ->
                    find_script(Envelope + 1, Max, Paths@1);

                _ ->
                    erlang:error(#{gleam_error => panic,
                            message => <<"Didn't expect a Cont here"/utf8>>,
                            module => <<"gap/myers"/utf8>>,
                            function => <<"find_script"/utf8>>,
                            line => 35})
            end
    end.

-spec difference(list(FUY), list(FUY)) -> list(edit(FUY)).
difference(List1, List2) ->
    Path = {path, 0, 0, List1, List2, []},
    find_script(0, gleam@list:length(List1) + gleam@list:length(List2), [Path]).

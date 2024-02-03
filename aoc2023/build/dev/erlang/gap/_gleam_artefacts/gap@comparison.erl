-module(gap@comparison).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function]).

-export_type([comparison/1, match/1]).

-type comparison(FSE) :: {list_comparison,
        list(match(list(FSE))),
        list(match(list(FSE)))} |
    {string_comparison,
        list(match(list(binary()))),
        list(match(list(binary())))}.

-type match(FSF) :: {match, FSF} | {no_match, FSF}.



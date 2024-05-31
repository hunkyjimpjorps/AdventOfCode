-module(gap@comparison).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function]).

-export_type([comparison/1, match/1]).

-type comparison(FQT) :: {list_comparison,
        list(match(list(FQT))),
        list(match(list(FQT)))} |
    {string_comparison,
        list(match(list(binary()))),
        list(match(list(binary())))}.

-type match(FQU) :: {match, FQU} | {no_match, FQU}.



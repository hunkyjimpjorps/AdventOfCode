-module(gap@comparison).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch]).

-export_type([comparison/1, match/1]).

-type comparison(NBT) :: {list_comparison,
        list(match(list(NBT))),
        list(match(list(NBT)))} |
    {string_comparison,
        list(match(list(binary()))),
        list(match(list(binary())))}.

-type match(NBU) :: {match, NBU} | {no_match, NBU}.



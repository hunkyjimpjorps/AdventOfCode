-module(gap@styled_comparison).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch]).

-export_type([styled_comparison/0]).

-type styled_comparison() :: {styled_comparison, binary(), binary()}.



-module(showtime@tests@meta).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function]).

-export_type([meta/0]).

-type meta() :: {meta, binary(), list(binary())}.



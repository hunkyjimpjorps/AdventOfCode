-module(showtime@internal@common@cli).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch]).

-export_type([capture/0]).

-type capture() :: yes | no | mixed.



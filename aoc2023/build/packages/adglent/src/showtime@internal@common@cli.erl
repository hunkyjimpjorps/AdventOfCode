-module(showtime@internal@common@cli).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function]).

-export_type([capture/0]).

-type capture() :: yes | no | mixed.



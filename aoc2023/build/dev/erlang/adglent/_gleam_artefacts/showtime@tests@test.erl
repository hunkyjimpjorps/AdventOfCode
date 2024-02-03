-module(showtime@tests@test).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function]).

-export([test/2, equal/3, not_equal/3, with_meta/2, be_ok/2, be_error/2, fail/1, be_true/2, be_false/2]).
-export_type([test/0, meta_should/1]).

-type test() :: {test, showtime@tests@meta:meta(), fun(() -> nil)}.

-type meta_should(OKH) :: {meta_should,
        fun((OKH, OKH) -> nil),
        fun((OKH, OKH) -> nil)}.

-spec test(showtime@tests@meta:meta(), fun((showtime@tests@meta:meta()) -> nil)) -> test().
test(Meta, Test_function) ->
    {test, Meta, fun() -> Test_function(Meta) end}.

-spec equal(OKM, OKM, showtime@tests@meta:meta()) -> nil.
equal(A, B, Meta) ->
    gleam@io:debug(A),
    gleam@io:debug(B),
    showtime@tests@should:equal_meta(A, B, Meta).

-spec not_equal(OKO, OKO, showtime@tests@meta:meta()) -> nil.
not_equal(A, B, Meta) ->
    showtime@tests@should:equal_meta(A, B, Meta).

-spec with_meta(showtime@tests@meta:meta(), fun((meta_should(any())) -> nil)) -> test().
with_meta(Meta, Test_function) ->
    {test,
        Meta,
        fun() ->
            Test_function(
                {meta_should,
                    fun(A, B) -> equal(A, B, Meta) end,
                    fun(A@1, B@1) -> not_equal(A@1, B@1, Meta) end}
            )
        end}.

-spec be_ok({ok, any()} | {error, any()}, showtime@tests@meta:meta()) -> nil.
be_ok(A, Meta) ->
    showtime@tests@should:be_ok_meta(A, Meta).

-spec be_error({ok, any()} | {error, any()}, showtime@tests@meta:meta()) -> nil.
be_error(A, Meta) ->
    showtime@tests@should:be_error_meta(A, Meta).

-spec fail(showtime@tests@meta:meta()) -> nil.
fail(Meta) ->
    showtime@tests@should:fail_meta(Meta).

-spec be_true(boolean(), showtime@tests@meta:meta()) -> nil.
be_true(A, Meta) ->
    showtime@tests@should:be_true_meta(A, Meta).

-spec be_false(boolean(), showtime@tests@meta:meta()) -> nil.
be_false(A, Meta) ->
    showtime@tests@should:be_false_meta(A, Meta).

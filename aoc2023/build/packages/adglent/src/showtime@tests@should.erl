-module(showtime@tests@should).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function]).

-export([evaluate/1, equal/2, equal_meta/3, not_equal/2, not_equal_meta/3, be_ok/1, be_ok_meta/2, be_error/1, be_error_meta/2, fail/0, fail_meta/1, be_true/1, be_true_meta/2, be_false/1, be_false_meta/2]).
-export_type([assertion/2]).

-type assertion(MXP, MXQ) :: {eq,
        MXP,
        MXP,
        gleam@option:option(showtime@tests@meta:meta())} |
    {not_eq, MXP, MXP, gleam@option:option(showtime@tests@meta:meta())} |
    {is_ok,
        {ok, MXP} | {error, MXQ},
        gleam@option:option(showtime@tests@meta:meta())} |
    {is_error,
        {ok, MXP} | {error, MXQ},
        gleam@option:option(showtime@tests@meta:meta())} |
    {fail, gleam@option:option(showtime@tests@meta:meta())}.

-spec evaluate(assertion(any(), any())) -> nil.
evaluate(Assertion) ->
    case Assertion of
        {eq, A, B, _} ->
            case A =:= B of
                true ->
                    nil;

                false ->
                    showtime_ffi:gleam_error({error, Assertion})
            end;

        {not_eq, A@1, B@1, _} ->
            case A@1 /= B@1 of
                true ->
                    nil;

                false ->
                    showtime_ffi:gleam_error({error, Assertion})
            end;

        {is_ok, A@2, _} ->
            case A@2 of
                {ok, _} ->
                    nil;

                {error, _} ->
                    showtime_ffi:gleam_error({error, Assertion})
            end;

        {is_error, A@3, _} ->
            case A@3 of
                {error, _} ->
                    nil;

                {ok, _} ->
                    showtime_ffi:gleam_error({error, Assertion})
            end;

        {fail, _} ->
            showtime_ffi:gleam_error({error, Assertion})
    end.

-spec equal(MXR, MXR) -> nil.
equal(A, B) ->
    evaluate({eq, A, B, none}).

-spec equal_meta(MXT, MXT, showtime@tests@meta:meta()) -> nil.
equal_meta(A, B, Meta) ->
    evaluate({eq, A, B, {some, Meta}}).

-spec not_equal(MXV, MXV) -> nil.
not_equal(A, B) ->
    evaluate({not_eq, A, B, none}).

-spec not_equal_meta(MXX, MXX, showtime@tests@meta:meta()) -> nil.
not_equal_meta(A, B, Meta) ->
    evaluate({not_eq, A, B, {some, Meta}}).

-spec be_ok({ok, MXZ} | {error, any()}) -> MXZ.
be_ok(A) ->
    evaluate({is_ok, A, none}),
    {ok, Value} = case A of
        {ok, _} -> A;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail,
                        module => <<"showtime/tests/should"/utf8>>,
                        function => <<"be_ok"/utf8>>,
                        line => 30})
    end,
    Value.

-spec be_ok_meta({ok, any()} | {error, any()}, showtime@tests@meta:meta()) -> nil.
be_ok_meta(A, Meta) ->
    evaluate({is_ok, A, {some, Meta}}).

-spec be_error({ok, any()} | {error, MYK}) -> MYK.
be_error(A) ->
    evaluate({is_error, A, none}),
    {error, Value} = case A of
        {error, _} -> A;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail,
                        module => <<"showtime/tests/should"/utf8>>,
                        function => <<"be_error"/utf8>>,
                        line => 40})
    end,
    Value.

-spec be_error_meta({ok, any()} | {error, any()}, showtime@tests@meta:meta()) -> nil.
be_error_meta(A, Meta) ->
    evaluate({is_error, A, {some, Meta}}).

-spec fail() -> nil.
fail() ->
    evaluate({fail, none}).

-spec fail_meta(showtime@tests@meta:meta()) -> nil.
fail_meta(Meta) ->
    evaluate({fail, {some, Meta}}).

-spec be_true(boolean()) -> nil.
be_true(A) ->
    _pipe = A,
    equal(_pipe, true).

-spec be_true_meta(boolean(), showtime@tests@meta:meta()) -> nil.
be_true_meta(A, Meta) ->
    _pipe = A,
    equal_meta(_pipe, true, Meta).

-spec be_false(boolean()) -> nil.
be_false(A) ->
    _pipe = A,
    equal(_pipe, false).

-spec be_false_meta(boolean(), showtime@tests@meta:meta()) -> nil.
be_false_meta(A, Meta) ->
    _pipe = A,
    equal_meta(_pipe, false, Meta).

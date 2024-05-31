-module(gleam_community@maths@conversion).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch]).

-export([int_to_float/1, float_to_int/1, degrees_to_radians/1, radians_to_degrees/1]).

-spec int_to_float(integer()) -> float().
int_to_float(X) ->
    gleam@int:to_float(X).

-spec float_to_int(float()) -> integer().
float_to_int(X) ->
    erlang:trunc(X).

-spec degrees_to_radians(float()) -> float().
degrees_to_radians(X) ->
    (X * math:pi()) / 180.0.

-spec radians_to_degrees(float()) -> float().
radians_to_degrees(X) ->
    case math:pi() of
        +0.0 -> +0.0;
        -0.0 -> -0.0;
        Gleam@denominator -> X * 180.0 / Gleam@denominator
    end.

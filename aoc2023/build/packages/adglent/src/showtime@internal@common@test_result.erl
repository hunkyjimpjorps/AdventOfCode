-module(showtime@internal@common@test_result).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function]).

-export_type([ignore_reason/0, test_return/0, exception/0, reason/0, reason_detail/0, gleam_error_detail/0, class/0, trace_list/0, trace/0, extra_info/0, arity_/0]).

-type ignore_reason() :: ignore.

-type test_return() :: {test_function_return,
        gleam@dynamic:dynamic_(),
        list(binary())} |
    {ignored, ignore_reason()}.

-type exception() :: {erlang_exception,
        class(),
        reason(),
        trace_list(),
        list(binary())}.

-type reason() :: {assert_equal, list(reason_detail())} |
    {assert_not_equal, list(reason_detail())} |
    {assert_match, list(reason_detail())} |
    {gleam_error, gleam_error_detail()} |
    {gleam_assert, gleam@dynamic:dynamic_(), integer()} |
    {generic_exception, gleam@dynamic:dynamic_()}.

-type reason_detail() :: {module, binary()} |
    {reason_line, integer()} |
    {expression, binary()} |
    {expected, gleam@dynamic:dynamic_()} |
    {value, gleam@dynamic:dynamic_()} |
    {pattern, binary()}.

-type gleam_error_detail() :: {let_assert,
        binary(),
        binary(),
        integer(),
        binary(),
        gleam@dynamic:dynamic_()}.

-type class() :: erlang_error | exit | throw.

-type trace_list() :: {trace_list, list(trace())}.

-type trace() :: {trace, binary(), arity_(), list(extra_info())} |
    {trace_module, binary(), binary(), arity_(), list(extra_info())}.

-type extra_info() :: {error_info,
        gleam@map:map_(gleam@dynamic:dynamic_(), gleam@dynamic:dynamic_())} |
    {file, binary()} |
    {line, integer()}.

-type arity_() :: {num, integer()} | {arg_list, list(gleam@dynamic:dynamic_())}.



-module(showtime@internal@erlang@event_handler).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch]).

-export([start/0]).
-export_type([event_handler_message/0]).

-type event_handler_message() :: {event_handler_message,
        showtime@internal@common@test_suite:test_event(),
        gleam@erlang@process:subject(integer())}.

-spec system_time() -> integer().
system_time() ->
    os:system_time(millisecond).

-spec start() -> fun((showtime@internal@common@test_suite:test_event()) -> nil).
start() ->
    _assert_subject = gleam@otp@actor:start(
        {not_started, 0, gleam@map:new()},
        fun(Msg, State) ->
            {event_handler_message, Test_event, Reply_to} = Msg,
            {Test_state, Num_done, Events} = State,
            Updated_state = showtime@internal@common@common_event_handler:handle_event(
                Test_event,
                fun system_time/0,
                {handler_state, Test_state, Num_done, Events}
            ),
            case Updated_state of
                {handler_state, {finished, Num_modules}, Num_done@1, Events@1} when Num_done@1 =:= Num_modules ->
                    {Test_report, Num_failed} = showtime@internal@reports@formatter:create_test_report(
                        Events@1
                    ),
                    gleam@io:println(Test_report),
                    gleam@erlang@process:send(Reply_to, Num_failed),
                    {stop, normal};

                {handler_state, Test_state@1, Num_done@2, Events@2} ->
                    {continue, {Test_state@1, Num_done@2, Events@2}, none}
            end
        end
    ),
    {ok, Subject} = case _assert_subject of
        {ok, _} -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail,
                        module => <<"showtime/internal/erlang/event_handler"/utf8>>,
                        function => <<"start"/utf8>>,
                        line => 32})
    end,
    Parent_subject = gleam@erlang@process:new_subject(),
    Selector = begin
        _pipe = gleam_erlang_ffi:new_selector(),
        gleam@erlang@process:selecting(_pipe, Parent_subject, fun(X) -> X end)
    end,
    fun(Test_event@1) -> case Test_event@1 of
            {end_test_run, _} ->
                gleam@erlang@process:send(
                    Subject,
                    {event_handler_message, Test_event@1, Parent_subject}
                ),
                Num_failed@1 = gleam_erlang_ffi:select(Selector),
                case Num_failed@1 > 0 of
                    true ->
                        erlang:halt(1);

                    false ->
                        erlang:halt(0)
                end;

            _ ->
                gleam@erlang@process:send(
                    Subject,
                    {event_handler_message, Test_event@1, Parent_subject}
                )
        end end.

-module(showtime@internal@common@common_event_handler).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function]).

-export([handle_event/3]).
-export_type([test_state/0, handler_state/0]).

-type test_state() :: not_started | running | {finished, integer()}.

-type handler_state() :: {handler_state,
        test_state(),
        integer(),
        gleam@map:map_(binary(), gleam@map:map_(binary(), showtime@internal@common@test_suite:test_run()))}.

-spec handle_event(
    showtime@internal@common@test_suite:test_event(),
    fun(() -> integer()),
    handler_state()
) -> handler_state().
handle_event(Msg, System_time, State) ->
    Test_state = erlang:element(2, State),
    Num_done = erlang:element(3, State),
    Events = erlang:element(4, State),
    {Updated_test_state, Updated_num_done, Updated_events} = case Msg of
        start_test_run ->
            {running, Num_done, Events};

        {start_test_suite, Module} ->
            Maybe_module_events = gleam@map:get(
                Events,
                erlang:element(2, Module)
            ),
            New_events = case Maybe_module_events of
                {ok, _} ->
                    Events;

                {error, _} ->
                    _pipe = Events,
                    gleam@map:insert(
                        _pipe,
                        erlang:element(2, Module),
                        gleam@map:new()
                    )
            end,
            {Test_state, Num_done, New_events};

        {start_test, Module@1, Test} ->
            Current_time = System_time(),
            Maybe_module_events@1 = gleam@map:get(
                Events,
                erlang:element(2, Module@1)
            ),
            New_events@1 = case Maybe_module_events@1 of
                {ok, Module_events} ->
                    Maybe_test_event = gleam@map:get(
                        Module_events,
                        erlang:element(2, Test)
                    ),
                    case Maybe_test_event of
                        {error, _} ->
                            _pipe@1 = Events,
                            gleam@map:insert(
                                _pipe@1,
                                erlang:element(2, Module@1),
                                begin
                                    _pipe@2 = Module_events,
                                    gleam@map:insert(
                                        _pipe@2,
                                        erlang:element(2, Test),
                                        {ongoing_test_run, Test, Current_time}
                                    )
                                end
                            );

                        {ok, _} ->
                            Events
                    end;

                {error, _} ->
                    Events
            end,
            {Test_state, Num_done, New_events@1};

        {end_test, Module@2, Test@1, Result} ->
            Current_time@1 = System_time(),
            Maybe_module_events@2 = gleam@map:get(
                Events,
                erlang:element(2, Module@2)
            ),
            New_events@2 = case Maybe_module_events@2 of
                {ok, Module_events@1} ->
                    Maybe_test_run = begin
                        _pipe@3 = Module_events@1,
                        gleam@map:get(_pipe@3, erlang:element(2, Test@1))
                    end,
                    Updated_module_events = case Maybe_test_run of
                        {ok, {ongoing_test_run, Test_function, Started_at}} ->
                            _pipe@4 = Module_events@1,
                            gleam@map:insert(
                                _pipe@4,
                                erlang:element(2, Test@1),
                                {completed_test_run,
                                    Test_function,
                                    Current_time@1 - Started_at,
                                    Result}
                            );

                        {error, _} ->
                            Module_events@1
                    end,
                    _pipe@5 = Events,
                    gleam@map:insert(
                        _pipe@5,
                        erlang:element(2, Module@2),
                        Updated_module_events
                    );

                {error, _} ->
                    Events
            end,
            {Test_state, Num_done, New_events@2};

        {end_test_suite, _} ->
            {Test_state, Num_done + 1, Events};

        {end_test_run, Num_modules} ->
            {{finished, Num_modules}, Num_done, Events};

        _ ->
            {running, Num_done, Events}
    end,
    {handler_state, Updated_test_state, Updated_num_done, Updated_events}.

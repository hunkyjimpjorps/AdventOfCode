-module(day20@solve).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch]).

-export([part1/1, part2/1, main/0]).
-export_type([node_/0, tone/0, power/0, tone_pitch/0, state/0]).

-type node_() :: {broadcaster, list(binary())} |
    {flipflop, list(binary()), power()} |
    {conjunction, list(binary()), gleam@dict:dict(binary(), tone_pitch())} |
    ground.

-type tone() :: {tone, binary(), binary(), tone_pitch()}.

-type power() :: on | off.

-type tone_pitch() :: low | high.

-type state() :: {state,
        gleam@dict:dict(binary(), node_()),
        integer(),
        integer(),
        integer(),
        gleam@dict:dict(binary(), integer())}.

-spec flip_power(power()) -> power().
flip_power(P) ->
    case P of
        on ->
            off;

        off ->
            on
    end.

-spec flip_flop_pitch(power()) -> tone_pitch().
flip_flop_pitch(P) ->
    case P of
        off ->
            high;

        on ->
            low
    end.

-spec combinator_pitch(gleam@dict:dict(any(), tone_pitch())) -> tone_pitch().
combinator_pitch(State) ->
    case gleam@list:unique(gleam@dict:values(State)) of
        [high] ->
            low;

        _ ->
            high
    end.

-spec get_children(node_()) -> list(binary()).
get_children(Node) ->
    case Node of
        {flipflop, Cs, _} ->
            Cs;

        {conjunction, Cs@1, _} ->
            Cs@1;

        {broadcaster, Cs@2} ->
            Cs@2;

        ground ->
            []
    end.

-spec parse_node(binary()) -> {binary(), node_()}.
parse_node(Input) ->
    _assert_subject = gleam@string:split(Input, <<" -> "/utf8>>),
    [Full_name, Children_str] = case _assert_subject of
        [_, _] -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail,
                        module => <<"day20/solve"/utf8>>,
                        function => <<"parse_node"/utf8>>,
                        line => 73})
    end,
    Children = gleam@string:split(Children_str, <<", "/utf8>>),
    case Full_name of
        <<"%"/utf8, Name/binary>> ->
            {Name, {flipflop, Children, off}};

        <<"&"/utf8, Name@1/binary>> ->
            {Name@1, {conjunction, Children, gleam@dict:new()}};

        <<"broadcaster"/utf8>> ->
            {<<"broadcaster"/utf8>>, {broadcaster, Children}};

        Name@2 ->
            {Name@2, ground}
    end.

-spec to_initial_state(list({binary(), node_()})) -> gleam@dict:dict(binary(), node_()).
to_initial_state(Nodes) ->
    Node_dict = gleam@dict:from_list(Nodes),
    Node_names = gleam@dict:keys(Node_dict),
    Node_dict@1 = begin
        _pipe = Node_dict,
        _pipe@1 = gleam@dict:values(_pipe),
        _pipe@2 = gleam@list:map(_pipe@1, fun get_children/1),
        _pipe@3 = gleam@list:concat(_pipe@2),
        _pipe@4 = gleam@set:from_list(_pipe@3),
        _pipe@5 = gleam@set:drop(_pipe@4, gleam@dict:keys(Node_dict)),
        _pipe@6 = gleam@set:to_list(_pipe@5),
        gleam@list:fold(
            _pipe@6,
            Node_dict,
            fun(Acc, N) -> gleam@dict:insert(Acc, N, ground) end
        )
    end,
    gleam@dict:map_values(Node_dict@1, fun(Name, Node) -> case Node of
                {conjunction, Chs, _} ->
                    _pipe@7 = Node_names,
                    _pipe@8 = gleam@list:filter(
                        _pipe@7,
                        fun(N@1) ->
                            _assert_subject = gleam@dict:get(Node_dict@1, N@1),
                            {ok, Node@1} = case _assert_subject of
                                {ok, _} -> _assert_subject;
                                _assert_fail ->
                                    erlang:error(#{gleam_error => let_assert,
                                                message => <<"Assertion pattern match failed"/utf8>>,
                                                value => _assert_fail,
                                                module => <<"day20/solve"/utf8>>,
                                                function => <<"to_initial_state"/utf8>>,
                                                line => 103})
                            end,
                            gleam@list:contains(get_children(Node@1), Name)
                        end
                    ),
                    _pipe@9 = gleam@list:map(
                        _pipe@8,
                        fun(N@2) -> {N@2, low} end
                    ),
                    _pipe@10 = gleam@dict:from_list(_pipe@9),
                    (fun(Dict) -> {conjunction, Chs, Dict} end)(_pipe@10);

                Other ->
                    Other
            end end).

-spec add_to_queue(
    binary(),
    list(binary()),
    tone_pitch(),
    gleam@queue:queue(tone())
) -> gleam@queue:queue(tone()).
add_to_queue(From, Children, Pitch, Queue) ->
    gleam@list:fold(
        Children,
        Queue,
        fun(Acc, C) -> gleam@queue:push_back(Acc, {tone, From, C, Pitch}) end
    ).

-spec add_tones(
    state(),
    gleam@dict:dict(binary(), node_()),
    tone_pitch(),
    integer()
) -> state().
add_tones(State, Nodes, Pitch, N) ->
    case Pitch of
        low ->
            erlang:setelement(
                5,
                erlang:setelement(
                    3,
                    erlang:setelement(2, State, Nodes),
                    erlang:element(3, State) + N
                ),
                erlang:element(5, State) + 1
            );

        high ->
            erlang:setelement(
                5,
                erlang:setelement(
                    4,
                    erlang:setelement(2, State, Nodes),
                    erlang:element(4, State) + N
                ),
                erlang:element(5, State) + 1
            )
    end.

-spec check_for_interesting_node(state(), binary(), tone_pitch()) -> state().
check_for_interesting_node(State, Name, Pitch_out) ->
    case {Name, Pitch_out} of
        {<<"rk"/utf8>>, high} ->
            erlang:setelement(
                6,
                State,
                gleam@dict:insert(
                    erlang:element(6, State),
                    Name,
                    erlang:element(5, State)
                )
            );

        {<<"cd"/utf8>>, high} ->
            erlang:setelement(
                6,
                State,
                gleam@dict:insert(
                    erlang:element(6, State),
                    Name,
                    erlang:element(5, State)
                )
            );

        {<<"zf"/utf8>>, high} ->
            erlang:setelement(
                6,
                State,
                gleam@dict:insert(
                    erlang:element(6, State),
                    Name,
                    erlang:element(5, State)
                )
            );

        {<<"qx"/utf8>>, high} ->
            erlang:setelement(
                6,
                State,
                gleam@dict:insert(
                    erlang:element(6, State),
                    Name,
                    erlang:element(5, State)
                )
            );

        {_, _} ->
            State
    end.

-spec press_button_once(state(), gleam@queue:queue(tone())) -> state().
press_button_once(Initial, Queue) ->
    {state, Nodes, _, _, _, _} = Initial,
    gleam@bool:guard(
        gleam@queue:is_empty(Queue),
        Initial,
        fun() ->
            _assert_subject = gleam@queue:pop_front(Queue),
            {ok, {{tone, From_name, To_name, Pitch}, Rest}} = case _assert_subject of
                {ok, {{tone, _, _, _}, _}} -> _assert_subject;
                _assert_fail ->
                    erlang:error(#{gleam_error => let_assert,
                                message => <<"Assertion pattern match failed"/utf8>>,
                                value => _assert_fail,
                                module => <<"day20/solve"/utf8>>,
                                function => <<"press_button_once"/utf8>>,
                                line => 131})
            end,
            _assert_subject@1 = gleam@dict:get(Nodes, To_name),
            {ok, To_node} = case _assert_subject@1 of
                {ok, _} -> _assert_subject@1;
                _assert_fail@1 ->
                    erlang:error(#{gleam_error => let_assert,
                                message => <<"Assertion pattern match failed"/utf8>>,
                                value => _assert_fail@1,
                                module => <<"day20/solve"/utf8>>,
                                function => <<"press_button_once"/utf8>>,
                                line => 134})
            end,
            case To_node of
                {broadcaster, Children} ->
                    New_state = add_tones(
                        Initial,
                        Nodes,
                        Pitch,
                        gleam@list:length(Children) + 1
                    ),
                    New_queue = add_to_queue(To_name, Children, Pitch, Rest),
                    press_button_once(New_state, New_queue);

                {conjunction, Children@1, State} ->
                    New_state@1 = begin
                        _pipe = State,
                        gleam@dict:insert(_pipe, From_name, Pitch)
                    end,
                    Updated_nodes = begin
                        _pipe@1 = {conjunction, Children@1, New_state@1},
                        gleam@dict:insert(Nodes, To_name, _pipe@1)
                    end,
                    Pitch_out = combinator_pitch(New_state@1),
                    New_state@2 = begin
                        _pipe@2 = add_tones(
                            Initial,
                            Updated_nodes,
                            Pitch_out,
                            gleam@list:length(Children@1)
                        ),
                        check_for_interesting_node(
                            _pipe@2,
                            From_name,
                            Pitch_out
                        )
                    end,
                    _pipe@3 = add_to_queue(To_name, Children@1, Pitch_out, Rest),
                    press_button_once(New_state@2, _pipe@3);

                {flipflop, _, _} when Pitch =:= high ->
                    press_button_once(
                        erlang:setelement(
                            5,
                            Initial,
                            erlang:element(5, Initial) + 1
                        ),
                        Rest
                    );

                {flipflop, Children@2, State@1} ->
                    Updated_nodes@1 = begin
                        _pipe@4 = {flipflop, Children@2, flip_power(State@1)},
                        gleam@dict:insert(Nodes, To_name, _pipe@4)
                    end,
                    Pitch_out@1 = flip_flop_pitch(State@1),
                    New_state@3 = add_tones(
                        Initial,
                        Updated_nodes@1,
                        Pitch_out@1,
                        gleam@list:length(Children@2)
                    ),
                    _pipe@5 = add_to_queue(
                        To_name,
                        Children@2,
                        flip_flop_pitch(State@1),
                        Rest
                    ),
                    press_button_once(New_state@3, _pipe@5);

                ground ->
                    press_button_once(
                        erlang:setelement(
                            5,
                            Initial,
                            erlang:element(5, Initial) + 1
                        ),
                        Rest
                    )
            end
        end
    ).

-spec part1(binary()) -> binary().
part1(Input) ->
    Initial_state = begin
        _pipe = Input,
        _pipe@1 = gleam@string:split(_pipe, <<"\n"/utf8>>),
        _pipe@2 = gleam@list:map(_pipe@1, fun parse_node/1),
        to_initial_state(_pipe@2)
    end,
    _pipe@3 = gleam@iterator:iterate(
        {state, Initial_state, 0, 0, 1, gleam@dict:new()},
        fun(_capture) ->
            press_button_once(
                _capture,
                gleam@queue:from_list(
                    [{tone, <<"button"/utf8>>, <<"broadcaster"/utf8>>, low}]
                )
            )
        end
    ),
    _pipe@4 = gleam@iterator:at(_pipe@3, 1000),
    _pipe@5 = (fun(S) ->
        {ok, {state, _, Low, High, _, _}} = case S of
            {ok, {state, _, _, _, _, _}} -> S;
            _assert_fail ->
                erlang:error(#{gleam_error => let_assert,
                            message => <<"Assertion pattern match failed"/utf8>>,
                            value => _assert_fail,
                            module => <<"day20/solve"/utf8>>,
                            function => <<"part1"/utf8>>,
                            line => 199})
        end,
        High * Low
    end)(_pipe@4),
    gleam@string:inspect(_pipe@5).

-spec part2(binary()) -> binary().
part2(Input) ->
    Initial_state = begin
        _pipe = Input,
        _pipe@1 = gleam@string:split(_pipe, <<"\n"/utf8>>),
        _pipe@2 = gleam@list:map(_pipe@1, fun parse_node/1),
        to_initial_state(_pipe@2)
    end,
    _pipe@3 = gleam@iterator:iterate(
        {state, Initial_state, 0, 0, 1, gleam@dict:new()},
        fun(_capture) ->
            press_button_once(
                _capture,
                gleam@queue:from_list(
                    [{tone, <<"button"/utf8>>, <<"broadcaster"/utf8>>, low}]
                )
            )
        end
    ),
    _pipe@4 = gleam@iterator:drop_while(
        _pipe@3,
        fun(S) -> gleam@dict:size(erlang:element(6, S)) < 4 end
    ),
    _pipe@5 = gleam@iterator:step(_pipe@4),
    _pipe@6 = (fun(S@1) ->
        {next, Goal, _} = case S@1 of
            {next, _, _} -> S@1;
            _assert_fail ->
                erlang:error(#{gleam_error => let_assert,
                            message => <<"Assertion pattern match failed"/utf8>>,
                            value => _assert_fail,
                            module => <<"day20/solve"/utf8>>,
                            function => <<"part2"/utf8>>,
                            line => 232})
        end,
        erlang:element(6, Goal)
    end)(_pipe@5),
    gleam@string:inspect(_pipe@6).

-spec main() -> nil.
main() ->
    _assert_subject = adglent:get_part(),
    {ok, Part} = case _assert_subject of
        {ok, _} -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail,
                        module => <<"day20/solve"/utf8>>,
                        function => <<"main"/utf8>>,
                        line => 239})
    end,
    _assert_subject@1 = adglent:get_input(<<"20"/utf8>>),
    {ok, Input} = case _assert_subject@1 of
        {ok, _} -> _assert_subject@1;
        _assert_fail@1 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail@1,
                        module => <<"day20/solve"/utf8>>,
                        function => <<"main"/utf8>>,
                        line => 240})
    end,
    case Part of
        first ->
            _pipe = part1(Input),
            _pipe@1 = adglent:inspect(_pipe),
            gleam@io:println(_pipe@1);

        second ->
            _pipe@2 = part2(Input),
            _pipe@3 = adglent:inspect(_pipe@2),
            gleam@io:println(_pipe@3)
    end.

-module(day20@solve).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function]).

-export([part1/1, part2/1, main/0]).
-export_type([node_/0, tone/0, power/0, tone_pitch/0]).

-type node_() :: {broadcaster, list(binary())} |
    {flipflop, list(binary()), power()} |
    {conjunction, list(binary()), gleam@dict:dict(binary(), tone_pitch())} |
    {ground, list(binary())}.

-type tone() :: {tone, binary(), binary(), tone_pitch()}.

-type power() :: on | off.

-type tone_pitch() :: low | high.

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
                        line => 45})
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
            {Name@2, {ground, []}}
    end.

-spec to_initial_state(list({binary(), node_()})) -> gleam@dict:dict(binary(), node_()).
to_initial_state(Nodes) ->
    Node_dict = gleam@dict:from_list(Nodes),
    Node_names = gleam@dict:keys(Node_dict),
    gleam@dict:map_values(Node_dict, fun(Name, Node) -> case Node of
                {conjunction, Chs, _} ->
                    _pipe = Node_names,
                    _pipe@1 = gleam@list:filter(
                        _pipe,
                        fun(N) ->
                            _assert_subject = gleam@dict:get(Node_dict, N),
                            {ok, Node@1} = case _assert_subject of
                                {ok, _} -> _assert_subject;
                                _assert_fail ->
                                    erlang:error(#{gleam_error => let_assert,
                                                message => <<"Assertion pattern match failed"/utf8>>,
                                                value => _assert_fail,
                                                module => <<"day20/solve"/utf8>>,
                                                function => <<"to_initial_state"/utf8>>,
                                                line => 65})
                            end,
                            gleam@list:contains(erlang:element(2, Node@1), Name)
                        end
                    ),
                    _pipe@2 = gleam@list:map(
                        _pipe@1,
                        fun(N@1) -> {N@1, low} end
                    ),
                    _pipe@3 = gleam@dict:from_list(_pipe@2),
                    (fun(Dict) -> {conjunction, Chs, Dict} end)(_pipe@3);

                Other ->
                    Other
            end end).

-spec press_button_once(
    {gleam@dict:dict(binary(), node_()), integer(), integer()},
    gleam@queue:queue(tone())
) -> {gleam@dict:dict(binary(), node_()), integer(), integer()}.
press_button_once(Initial, Queue) ->
    {Nodes, High, Low} = Initial,
    gleam@bool:guard(
        gleam@queue:is_empty(Queue),
        Initial,
        fun() ->
            _assert_subject = gleam@queue:pop_front(Queue),
            {ok, {{tone, From_name, To_name, Pitch} = Tone, Rest}} = case _assert_subject of
                {ok, {{tone, _, _, _}, _}} -> _assert_subject;
                _assert_fail ->
                    erlang:error(#{gleam_error => let_assert,
                                message => <<"Assertion pattern match failed"/utf8>>,
                                value => _assert_fail,
                                module => <<"day20/solve"/utf8>>,
                                function => <<"press_button_once"/utf8>>,
                                line => 81})
            end,
            gleam@io:debug(Tone),
            _assert_subject@1 = gleam@dict:get(Nodes, To_name),
            {ok, To_node} = case _assert_subject@1 of
                {ok, _} -> _assert_subject@1;
                _assert_fail@1 ->
                    erlang:error(#{gleam_error => let_assert,
                                message => <<"Assertion pattern match failed"/utf8>>,
                                value => _assert_fail@1,
                                module => <<"day20/solve"/utf8>>,
                                function => <<"press_button_once"/utf8>>,
                                line => 84})
            end,
            case To_node of
                {broadcaster, Children} ->
                    _pipe = gleam@list:fold(
                        Children,
                        Rest,
                        fun(Acc, C) ->
                            gleam@queue:push_back(
                                Acc,
                                {tone, To_name, C, Pitch}
                            )
                        end
                    ),
                    press_button_once(Initial, _pipe);

                {conjunction, _, _} ->
                    press_button_once(Initial, Rest);

                {flipflop, _, _} when Pitch =:= high ->
                    press_button_once(Initial, Rest);

                {flipflop, Children@1, State} ->
                    Updated_nodes = gleam@dict:insert(
                        Nodes,
                        To_name,
                        {flipflop, Children@1, flip_power(State)}
                    ),
                    Updated_queue = gleam@list:fold(
                        Children@1,
                        Rest,
                        fun(Acc@1, C@1) ->
                            gleam@queue:push_back(
                                Acc@1,
                                {tone, To_name, C@1, flip_flop_pitch(State)}
                            )
                        end
                    ),
                    press_button_once({Updated_nodes, 0, 0}, Updated_queue);

                {ground, _} ->
                    press_button_once(Initial, Rest)
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
    press_button_once(
        {Initial_state, 0, 1},
        begin
            _pipe@3 = [{tone, <<"button"/utf8>>, <<"broadcaster"/utf8>>, low}],
            gleam@queue:from_list(_pipe@3)
        end
    ),
    <<"1"/utf8>>.

-spec part2(binary()) -> any().
part2(Input) ->
    erlang:error(#{gleam_error => todo,
            message => <<"Implement solution to part 2"/utf8>>,
            module => <<"day20/solve"/utf8>>,
            function => <<"part2"/utf8>>,
            line => 130}).

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
                        line => 134})
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
                        line => 135})
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

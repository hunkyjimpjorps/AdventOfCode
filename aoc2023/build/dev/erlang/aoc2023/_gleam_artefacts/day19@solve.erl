-module(day19@solve).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch]).

-export([part1/1, part2/1, main/0]).
-export_type([rating/0, part/0, action/0, rule/0, interval/0, part_range/0]).

-type rating() :: xtremely_cool | musical | aerodynamic | shiny.

-type part() :: {part, integer(), integer(), integer(), integer()}.

-type action() :: accept | reject | {send_to, binary()}.

-type rule() :: {'if', rating(), gleam@order:order(), integer(), action()} |
    {just, action()}.

-type interval() :: {interval, integer(), integer()}.

-type part_range() :: {part_range,
        interval(),
        interval(),
        interval(),
        interval()}.

-spec to_instruction(binary()) -> action().
to_instruction(Rule) ->
    case Rule of
        <<"A"/utf8>> ->
            accept;

        <<"R"/utf8>> ->
            reject;

        Name ->
            {send_to, Name}
    end.

-spec to_rating(binary()) -> rating().
to_rating(Rating) ->
    case Rating of
        <<"x"/utf8>> ->
            xtremely_cool;

        <<"m"/utf8>> ->
            musical;

        <<"a"/utf8>> ->
            aerodynamic;

        _ ->
            shiny
    end.

-spec get_rating(part(), rating()) -> integer().
get_rating(Part, Rating) ->
    case Rating of
        xtremely_cool ->
            erlang:element(2, Part);

        musical ->
            erlang:element(3, Part);

        aerodynamic ->
            erlang:element(4, Part);

        shiny ->
            erlang:element(5, Part)
    end.

-spec to_comp(binary()) -> gleam@order:order().
to_comp(Comp) ->
    case Comp of
        <<"<"/utf8>> ->
            lt;

        _ ->
            gt
    end.

-spec to_val(binary()) -> integer().
to_val(Val) ->
    _assert_subject = gleam@int:parse(Val),
    {ok, N} = case _assert_subject of
        {ok, _} -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail,
                        module => <<"day19/solve"/utf8>>,
                        function => <<"to_val"/utf8>>,
                        line => 100})
    end,
    N.

-spec parse_rules(list(binary())) -> list(rule()).
parse_rules(Rules) ->
    _assert_subject = gleam@regex:from_string(<<"(.*)(>|<)(.*):(.*)"/utf8>>),
    {ok, Re_rule} = case _assert_subject of
        {ok, _} -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail,
                        module => <<"day19/solve"/utf8>>,
                        function => <<"parse_rules"/utf8>>,
                        line => 57})
    end,
    gleam@list:map(Rules, fun(Rule) -> case gleam@regex:scan(Re_rule, Rule) of
                [{match, _, [{some, R}, {some, C}, {some, T}, {some, I}]}] ->
                    {'if',
                        to_rating(R),
                        to_comp(C),
                        to_val(T),
                        to_instruction(I)};

                _ ->
                    {just, to_instruction(Rule)}
            end end).

-spec parse_workflow(binary()) -> gleam@dict:dict(binary(), list(rule())).
parse_workflow(Input) ->
    _assert_subject = gleam@regex:from_string(<<"(.*){(.*)}"/utf8>>),
    {ok, Re} = case _assert_subject of
        {ok, _} -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail,
                        module => <<"day19/solve"/utf8>>,
                        function => <<"parse_workflow"/utf8>>,
                        line => 45})
    end,
    gleam@list:fold(
        gleam@string:split(Input, <<"\n"/utf8>>),
        gleam@dict:new(),
        fun(Acc, Line) ->
            _assert_subject@1 = gleam@regex:scan(Re, Line),
            [{match, _, [{some, Name}, {some, All_rules}]}] = case _assert_subject@1 of
                [{match, _, [{some, _}, {some, _}]}] -> _assert_subject@1;
                _assert_fail@1 ->
                    erlang:error(#{gleam_error => let_assert,
                                message => <<"Assertion pattern match failed"/utf8>>,
                                value => _assert_fail@1,
                                module => <<"day19/solve"/utf8>>,
                                function => <<"parse_workflow"/utf8>>,
                                line => 48})
            end,
            Rules = begin
                _pipe = gleam@string:split(All_rules, <<","/utf8>>),
                parse_rules(_pipe)
            end,
            gleam@dict:insert(Acc, Name, Rules)
        end
    ).

-spec parse_parts(binary()) -> list(part()).
parse_parts(Input) ->
    _assert_subject = gleam@regex:from_string(
        <<"{x=(.*),m=(.*),a=(.*),s=(.*)}"/utf8>>
    ),
    {ok, Re} = case _assert_subject of
        {ok, _} -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail,
                        module => <<"day19/solve"/utf8>>,
                        function => <<"parse_parts"/utf8>>,
                        line => 105})
    end,
    gleam@list:map(
        gleam@string:split(Input, <<"\n"/utf8>>),
        fun(Part) ->
            _assert_subject@1 = gleam@regex:scan(Re, Part),
            [{match, _, [{some, X}, {some, M}, {some, A}, {some, S}]}] = case _assert_subject@1 of
                [{match, _, [{some, _}, {some, _}, {some, _}, {some, _}]}] -> _assert_subject@1;
                _assert_fail@1 ->
                    erlang:error(#{gleam_error => let_assert,
                                message => <<"Assertion pattern match failed"/utf8>>,
                                value => _assert_fail@1,
                                module => <<"day19/solve"/utf8>>,
                                function => <<"parse_parts"/utf8>>,
                                line => 108})
            end,
            {part, to_val(X), to_val(M), to_val(A), to_val(S)}
        end
    ).

-spec evaluate_rules(part(), list(rule())) -> action().
evaluate_rules(Part, Rules) ->
    case Rules of
        [] ->
            erlang:error(#{gleam_error => panic,
                    message => <<"panic expression evaluated"/utf8>>,
                    module => <<"day19/solve"/utf8>>,
                    function => <<"evaluate_rules"/utf8>>,
                    line => 128});

        [{just, Do} | _] ->
            Do;

        [{'if', Rating, Comparison, Threshold, Do@1} | Rest] ->
            case gleam@int:compare(get_rating(Part, Rating), Threshold) =:= Comparison of
                true ->
                    Do@1;

                false ->
                    evaluate_rules(Part, Rest)
            end
    end.

-spec evaluate_workflow(
    part(),
    binary(),
    gleam@dict:dict(binary(), list(rule()))
) -> integer().
evaluate_workflow(Part, Name, Workflow) ->
    _assert_subject = gleam@dict:get(Workflow, Name),
    {ok, Rules} = case _assert_subject of
        {ok, _} -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail,
                        module => <<"day19/solve"/utf8>>,
                        function => <<"evaluate_workflow"/utf8>>,
                        line => 118})
    end,
    case evaluate_rules(Part, Rules) of
        accept ->
            ((erlang:element(2, Part) + erlang:element(3, Part)) + erlang:element(
                4,
                Part
            ))
            + erlang:element(5, Part);

        reject ->
            0;

        {send_to, Name@1} ->
            evaluate_workflow(Part, Name@1, Workflow)
    end.

-spec start_evaluating_workflow(part(), gleam@dict:dict(binary(), list(rule()))) -> integer().
start_evaluating_workflow(Part, Workflow) ->
    evaluate_workflow(Part, <<"in"/utf8>>, Workflow).

-spec part1(binary()) -> binary().
part1(Input) ->
    _assert_subject = gleam@string:split_once(Input, <<"\n\n"/utf8>>),
    {ok, {Workflows_str, Parts_str}} = case _assert_subject of
        {ok, {_, _}} -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail,
                        module => <<"day19/solve"/utf8>>,
                        function => <<"part1"/utf8>>,
                        line => 139})
    end,
    Workflows = parse_workflow(Workflows_str),
    Parts = parse_parts(Parts_str),
    _pipe = gleam@list:map(
        Parts,
        fun(_capture) -> start_evaluating_workflow(_capture, Workflows) end
    ),
    _pipe@1 = gleam@int:sum(_pipe),
    gleam@string:inspect(_pipe@1).

-spec size(interval()) -> integer().
size(Interval) ->
    (erlang:element(3, Interval) - erlang:element(2, Interval)) + 1.

-spec all_in_range(part_range()) -> integer().
all_in_range(Pr) ->
    ((size(erlang:element(2, Pr)) * size(erlang:element(3, Pr))) * size(
        erlang:element(4, Pr)
    ))
    * size(erlang:element(5, Pr)).

-spec get_partrange(part_range(), rating()) -> interval().
get_partrange(Pr, Rating) ->
    case Rating of
        xtremely_cool ->
            erlang:element(2, Pr);

        musical ->
            erlang:element(3, Pr);

        aerodynamic ->
            erlang:element(4, Pr);

        shiny ->
            erlang:element(5, Pr)
    end.

-spec update_partrange(part_range(), rating(), interval()) -> part_range().
update_partrange(Pr, Rating, I) ->
    case Rating of
        xtremely_cool ->
            erlang:setelement(2, Pr, I);

        musical ->
            erlang:setelement(3, Pr, I);

        aerodynamic ->
            erlang:setelement(4, Pr, I);

        shiny ->
            erlang:setelement(5, Pr, I)
    end.

-spec evaluate_rules_on_range(
    part_range(),
    list(rule()),
    gleam@dict:dict(binary(), list(rule()))
) -> integer().
evaluate_rules_on_range(Pr, Rules, Workflow) ->
    case Rules of
        [{just, accept} | _] ->
            all_in_range(Pr);

        [{just, reject} | _] ->
            0;

        [{just, {send_to, Name}} | _] ->
            evaluate_workflow_on_range(Pr, Name, Workflow);

        [{'if', Rating, Comparison, T, Action} | Rest] ->
            Mod_i = get_partrange(Pr, Rating),
            case Comparison of
                lt ->
                    split_range(
                        update_partrange(
                            Pr,
                            Rating,
                            {interval, erlang:element(2, Mod_i), T - 1}
                        ),
                        Action,
                        update_partrange(
                            Pr,
                            Rating,
                            {interval, T, erlang:element(3, Mod_i)}
                        ),
                        Rest,
                        Workflow
                    );

                _ ->
                    split_range(
                        update_partrange(
                            Pr,
                            Rating,
                            {interval, T + 1, erlang:element(3, Mod_i)}
                        ),
                        Action,
                        update_partrange(
                            Pr,
                            Rating,
                            {interval, erlang:element(2, Mod_i), T}
                        ),
                        Rest,
                        Workflow
                    )
            end;

        [] ->
            erlang:error(#{gleam_error => panic,
                    message => <<"panic expression evaluated"/utf8>>,
                    module => <<"day19/solve"/utf8>>,
                    function => <<"evaluate_rules_on_range"/utf8>>,
                    line => 225})
    end.

-spec evaluate_workflow_on_range(
    part_range(),
    binary(),
    gleam@dict:dict(binary(), list(rule()))
) -> integer().
evaluate_workflow_on_range(Pr, Name, Workflow) ->
    _assert_subject = gleam@dict:get(Workflow, Name),
    {ok, Rules} = case _assert_subject of
        {ok, _} -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail,
                        module => <<"day19/solve"/utf8>>,
                        function => <<"evaluate_workflow_on_range"/utf8>>,
                        line => 191})
    end,
    evaluate_rules_on_range(Pr, Rules, Workflow).

-spec part2(binary()) -> binary().
part2(Input) ->
    _assert_subject = gleam@string:split_once(Input, <<"\n\n"/utf8>>),
    {ok, {Workflows_str, _}} = case _assert_subject of
        {ok, {_, _}} -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail,
                        module => <<"day19/solve"/utf8>>,
                        function => <<"part2"/utf8>>,
                        line => 176})
    end,
    Workflow = parse_workflow(Workflows_str),
    Start = {interval, 1, 4000},
    _pipe = {part_range, Start, Start, Start, Start},
    _pipe@1 = evaluate_workflow_on_range(_pipe, <<"in"/utf8>>, Workflow),
    gleam@string:inspect(_pipe@1).

-spec split_range(
    part_range(),
    action(),
    part_range(),
    list(rule()),
    gleam@dict:dict(binary(), list(rule()))
) -> integer().
split_range(Keep, Action, Pass, Rest, Workflow) ->
    gleam@int:add(
        evaluate_rules_on_range(Keep, [{just, Action}], Workflow),
        evaluate_rules_on_range(Pass, Rest, Workflow)
    ).

-spec main() -> nil.
main() ->
    _assert_subject = adglent:get_part(),
    {ok, Part} = case _assert_subject of
        {ok, _} -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail,
                        module => <<"day19/solve"/utf8>>,
                        function => <<"main"/utf8>>,
                        line => 243})
    end,
    _assert_subject@1 = adglent:get_input(<<"19"/utf8>>),
    {ok, Input} = case _assert_subject@1 of
        {ok, _} -> _assert_subject@1;
        _assert_fail@1 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail@1,
                        module => <<"day19/solve"/utf8>>,
                        function => <<"main"/utf8>>,
                        line => 244})
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

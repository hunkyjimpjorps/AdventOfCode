-module(utilities@prioqueue).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function]).

-export([new/0, insert/3, pop/1]).
-export_type([ref/0, p_queue/1, priority_queue/1, out_result/1]).

-type ref() :: any().

-type p_queue(BBO) :: any() | {gleam_phantom, BBO}.

-opaque priority_queue(BBP) :: {priority_queue,
        p_queue({BBP, ref()}),
        gleam@dict:dict(BBP, ref())}.

-type out_result(BBQ) :: empty | {value, BBQ, integer()}.

-spec new() -> priority_queue(any()).
new() ->
    {priority_queue, pqueue2:new(), gleam@dict:new()}.

-spec insert(priority_queue(BCC), BCC, integer()) -> priority_queue(BCC).
insert(Queue, Value, Priority) ->
    Ref = erlang:make_ref(),
    Refs = begin
        _pipe = erlang:element(3, Queue),
        gleam@dict:insert(_pipe, Value, Ref)
    end,
    {priority_queue,
        pqueue2:in({Value, Ref}, Priority, erlang:element(2, Queue)),
        Refs}.

-spec pop(priority_queue(BCF)) -> {ok, {BCF, priority_queue(BCF)}} |
    {error, nil}.
pop(Queue) ->
    case pqueue2:pout(erlang:element(2, Queue)) of
        {{value, {Value, Ref}, _}, Pqueue} ->
            _assert_subject = gleam@dict:get(erlang:element(3, Queue), Value),
            {ok, Recently_enqueued_ref} = case _assert_subject of
                {ok, _} -> _assert_subject;
                _assert_fail ->
                    erlang:error(#{gleam_error => let_assert,
                                message => <<"Assertion pattern match failed"/utf8>>,
                                value => _assert_fail,
                                module => <<"utilities/prioqueue"/utf8>>,
                                function => <<"pop"/utf8>>,
                                line => 52})
            end,
            case Recently_enqueued_ref =:= Ref of
                true ->
                    {ok,
                        {Value,
                            {priority_queue, Pqueue, erlang:element(3, Queue)}}};

                false ->
                    pop({priority_queue, Pqueue, erlang:element(3, Queue)})
            end;

        {empty, _} ->
            {error, nil}
    end.

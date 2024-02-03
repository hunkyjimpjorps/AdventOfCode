-module(day15@solve).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function]).

-export([part1/1, part2/1, main/0]).
-export_type([instruction/0]).

-type instruction() :: {remove, binary()} | {insert, binary(), integer()}.

-spec split(binary()) -> list(binary()).
split(Input) ->
    _pipe = Input,
    gleam@string:split(_pipe, <<","/utf8>>).

-spec hash_algorithm(binary()) -> integer().
hash_algorithm(Str) ->
    Codepoints = begin
        _pipe = Str,
        _pipe@1 = gleam@string:to_utf_codepoints(_pipe),
        gleam@list:map(_pipe@1, fun gleam@string:utf_codepoint_to_int/1)
    end,
    gleam@list:fold(
        Codepoints,
        0,
        fun(Acc, C) ->
            _assert_subject = gleam@int:modulo((Acc + C) * 17, 256),
            {ok, Acc@1} = case _assert_subject of
                {ok, _} -> _assert_subject;
                _assert_fail ->
                    erlang:error(#{gleam_error => let_assert,
                                message => <<"Assertion pattern match failed"/utf8>>,
                                value => _assert_fail,
                                module => <<"day15/solve"/utf8>>,
                                function => <<"hash_algorithm"/utf8>>,
                                line => 20})
            end,
            Acc@1
        end
    ).

-spec part1(binary()) -> binary().
part1(Input) ->
    _pipe = Input,
    _pipe@1 = split(_pipe),
    _pipe@2 = gleam@list:fold(
        _pipe@1,
        0,
        fun(Acc, Str) -> Acc + hash_algorithm(Str) end
    ),
    gleam@string:inspect(_pipe@2).

-spec read_instruction(binary()) -> instruction().
read_instruction(Str) ->
    case gleam@string:split(Str, <<"="/utf8>>) of
        [Label, Focal_str] ->
            _assert_subject = gleam@int:parse(Focal_str),
            {ok, Focal} = case _assert_subject of
                {ok, _} -> _assert_subject;
                _assert_fail ->
                    erlang:error(#{gleam_error => let_assert,
                                message => <<"Assertion pattern match failed"/utf8>>,
                                value => _assert_fail,
                                module => <<"day15/solve"/utf8>>,
                                function => <<"read_instruction"/utf8>>,
                                line => 39})
            end,
            {insert, Label, Focal};

        _ ->
            {remove, gleam@string:drop_right(Str, 1)}
    end.

-spec remove_lens(gleam@dict:dict(integer(), list({binary(), BPV})), binary()) -> gleam@dict:dict(integer(), list({binary(),
    BPV})).
remove_lens(Boxes, Label) ->
    gleam@dict:update(Boxes, hash_algorithm(Label), fun(V) -> case V of
                {some, Lenses} ->
                    case gleam@list:key_pop(Lenses, Label) of
                        {ok, {_, Updated}} ->
                            Updated;

                        {error, nil} ->
                            Lenses
                    end;

                none ->
                    []
            end end).

-spec insert_lens(
    gleam@dict:dict(integer(), list({binary(), BON})),
    binary(),
    BON
) -> gleam@dict:dict(integer(), list({binary(), BON})).
insert_lens(Boxes, Label, Focal) ->
    gleam@dict:update(Boxes, hash_algorithm(Label), fun(V) -> case V of
                {some, Lenses} ->
                    gleam@list:key_set(Lenses, Label, Focal);

                none ->
                    [{Label, Focal}]
            end end).

-spec parse_instructions(list(binary())) -> gleam@dict:dict(integer(), list({binary(),
    integer()})).
parse_instructions(Insts) ->
    gleam@list:fold(
        Insts,
        gleam@dict:new(),
        fun(Acc, Inst) -> case read_instruction(Inst) of
                {remove, Label} ->
                    remove_lens(Acc, Label);

                {insert, Label@1, Focal} ->
                    insert_lens(Acc, Label@1, Focal)
            end end
    ).

-spec focusing_power(gleam@dict:dict(integer(), list({binary(), integer()}))) -> integer().
focusing_power(Boxes) ->
    gleam@dict:fold(
        Boxes,
        0,
        fun(Acc, K, V) ->
            Box_acc = (gleam@list:index_fold(
                V,
                0,
                fun(Acc@1, Lens, I) ->
                    Acc@1 + (erlang:element(2, Lens) * (I + 1))
                end
            )),
            Acc + ((K + 1) * Box_acc)
        end
    ).

-spec part2(binary()) -> binary().
part2(Input) ->
    _pipe = Input,
    _pipe@1 = split(_pipe),
    _pipe@2 = parse_instructions(_pipe@1),
    _pipe@3 = focusing_power(_pipe@2),
    gleam@string:inspect(_pipe@3).

-spec main() -> nil.
main() ->
    _assert_subject = adglent:get_part(),
    {ok, Part} = case _assert_subject of
        {ok, _} -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail,
                        module => <<"day15/solve"/utf8>>,
                        function => <<"main"/utf8>>,
                        line => 92})
    end,
    _assert_subject@1 = adglent:get_input(<<"15"/utf8>>),
    {ok, Input} = case _assert_subject@1 of
        {ok, _} -> _assert_subject@1;
        _assert_fail@1 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Assertion pattern match failed"/utf8>>,
                        value => _assert_fail@1,
                        module => <<"day15/solve"/utf8>>,
                        function => <<"main"/utf8>>,
                        line => 93})
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

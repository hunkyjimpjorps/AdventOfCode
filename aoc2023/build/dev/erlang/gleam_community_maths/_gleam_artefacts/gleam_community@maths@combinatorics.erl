-module(gleam_community@maths@combinatorics).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch]).

-export([combination/2, factorial/1, permutation/2, list_combination/2, list_permutation/1, cartesian_product/2]).

-spec combination(integer(), integer()) -> {ok, integer()} | {error, binary()}.
combination(N, K) ->
    case N < 0 of
        true ->
            _pipe = <<"Invalid input argument: n < 0. Valid input is n > 0."/utf8>>,
            {error, _pipe};

        false ->
            case (K < 0) orelse (K > N) of
                true ->
                    _pipe@1 = 0,
                    {ok, _pipe@1};

                false ->
                    case (K =:= 0) orelse (K =:= N) of
                        true ->
                            _pipe@2 = 1,
                            {ok, _pipe@2};

                        false ->
                            Min = case K < (N - K) of
                                true ->
                                    K;

                                false ->
                                    N - K
                            end,
                            _pipe@3 = gleam@list:range(1, Min),
                            _pipe@4 = gleam@list:fold(
                                _pipe@3,
                                1,
                                fun(Acc, X) -> case X of
                                        0 -> 0;
                                        Gleam@denominator -> Acc * ((N + 1) - X)
                                        div Gleam@denominator
                                    end end
                            ),
                            {ok, _pipe@4}
                    end
            end
    end.

-spec factorial(integer()) -> {ok, integer()} | {error, binary()}.
factorial(N) ->
    case N < 0 of
        true ->
            _pipe = <<"Invalid input argument: n < 0. Valid input is n > 0."/utf8>>,
            {error, _pipe};

        false ->
            case N of
                0 ->
                    _pipe@1 = 1,
                    {ok, _pipe@1};

                1 ->
                    _pipe@2 = 1,
                    {ok, _pipe@2};

                _ ->
                    _pipe@3 = gleam@list:range(1, N),
                    _pipe@4 = gleam@list:fold(
                        _pipe@3,
                        1,
                        fun(Acc, X) -> Acc * X end
                    ),
                    {ok, _pipe@4}
            end
    end.

-spec permutation(integer(), integer()) -> {ok, integer()} | {error, binary()}.
permutation(N, K) ->
    case N < 0 of
        true ->
            _pipe = <<"Invalid input argument: n < 0. Valid input is n > 0."/utf8>>,
            {error, _pipe};

        false ->
            case (K < 0) orelse (K > N) of
                true ->
                    _pipe@1 = 0,
                    {ok, _pipe@1};

                false ->
                    case K =:= N of
                        true ->
                            _pipe@2 = 1,
                            {ok, _pipe@2};

                        false ->
                            _assert_subject = factorial(N),
                            {ok, V1} = case _assert_subject of
                                {ok, _} -> _assert_subject;
                                _assert_fail ->
                                    erlang:error(#{gleam_error => let_assert,
                                                message => <<"Assertion pattern match failed"/utf8>>,
                                                value => _assert_fail,
                                                module => <<"gleam_community/maths/combinatorics"/utf8>>,
                                                function => <<"permutation"/utf8>>,
                                                line => 241})
                            end,
                            _assert_subject@1 = factorial(N - K),
                            {ok, V2} = case _assert_subject@1 of
                                {ok, _} -> _assert_subject@1;
                                _assert_fail@1 ->
                                    erlang:error(#{gleam_error => let_assert,
                                                message => <<"Assertion pattern match failed"/utf8>>,
                                                value => _assert_fail@1,
                                                module => <<"gleam_community/maths/combinatorics"/utf8>>,
                                                function => <<"permutation"/utf8>>,
                                                line => 242})
                            end,
                            _pipe@3 = case V2 of
                                0 -> 0;
                                Gleam@denominator -> V1 div Gleam@denominator
                            end,
                            {ok, _pipe@3}
                    end
            end
    end.

-spec do_list_combination(list(JGD), integer(), list(JGD)) -> list(list(JGD)).
do_list_combination(Arr, K, Prefix) ->
    case K of
        0 ->
            [gleam@list:reverse(Prefix)];

        _ ->
            case Arr of
                [] ->
                    [];

                [X | Xs] ->
                    With_x = do_list_combination(Xs, K - 1, [X | Prefix]),
                    Without_x = do_list_combination(Xs, K, Prefix),
                    gleam@list:append(With_x, Without_x)
            end
    end.

-spec list_combination(list(JFX), integer()) -> {ok, list(list(JFX))} |
    {error, binary()}.
list_combination(Arr, K) ->
    case K < 0 of
        true ->
            _pipe = <<"Invalid input argument: k < 0. Valid input is k > 0."/utf8>>,
            {error, _pipe};

        false ->
            case K > gleam@list:length(Arr) of
                true ->
                    _pipe@1 = <<"Invalid input argument: k > length(arr). Valid input is 0 < k <= length(arr)."/utf8>>,
                    {error, _pipe@1};

                false ->
                    _pipe@2 = do_list_combination(Arr, K, []),
                    {ok, _pipe@2}
            end
    end.

-spec list_permutation(list(JGI)) -> list(list(JGI)).
list_permutation(Arr) ->
    case Arr of
        [] ->
            [[]];

        _ ->
            gleam@list:flat_map(
                Arr,
                fun(X) ->
                    _assert_subject = gleam@list:pop(Arr, fun(Y) -> X =:= Y end),
                    {ok, {_, Remaining}} = case _assert_subject of
                        {ok, {_, _}} -> _assert_subject;
                        _assert_fail ->
                            erlang:error(#{gleam_error => let_assert,
                                        message => <<"Assertion pattern match failed"/utf8>>,
                                        value => _assert_fail,
                                        module => <<"gleam_community/maths/combinatorics"/utf8>>,
                                        function => <<"list_permutation"/utf8>>,
                                        line => 373})
                    end,
                    gleam@list:map(
                        list_permutation(Remaining),
                        fun(Perm) -> [X | Perm] end
                    )
                end
            )
    end.

-spec cartesian_product(list(JGM), list(JGM)) -> list({JGM, JGM}).
cartesian_product(Xarr, Yarr) ->
    Xset = begin
        _pipe = Xarr,
        gleam@set:from_list(_pipe)
    end,
    Yset = begin
        _pipe@1 = Yarr,
        gleam@set:from_list(_pipe@1)
    end,
    _pipe@2 = Xset,
    _pipe@3 = gleam@set:fold(
        _pipe@2,
        gleam@set:new(),
        fun(Accumulator0, Member0) ->
            gleam@set:fold(
                Yset,
                Accumulator0,
                fun(Accumulator1, Member1) ->
                    gleam@set:insert(Accumulator1, {Member0, Member1})
                end
            )
        end
    ),
    gleam@set:to_list(_pipe@3).

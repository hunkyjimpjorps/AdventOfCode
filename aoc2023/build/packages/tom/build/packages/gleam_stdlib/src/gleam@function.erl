-module(gleam@function).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch]).

-export([compose/2, curry2/1, curry3/1, curry4/1, curry5/1, curry6/1, flip/1, identity/1, constant/1, tap/2, apply1/2, apply2/3, apply3/4]).

-spec compose(fun((DJZ) -> DKA), fun((DKA) -> DKB)) -> fun((DJZ) -> DKB).
compose(Fun1, Fun2) ->
    fun(A) -> Fun2(Fun1(A)) end.

-spec curry2(fun((DKC, DKD) -> DKE)) -> fun((DKC) -> fun((DKD) -> DKE)).
curry2(Fun) ->
    fun(A) -> fun(B) -> Fun(A, B) end end.

-spec curry3(fun((DKG, DKH, DKI) -> DKJ)) -> fun((DKG) -> fun((DKH) -> fun((DKI) -> DKJ))).
curry3(Fun) ->
    fun(A) -> fun(B) -> fun(C) -> Fun(A, B, C) end end end.

-spec curry4(fun((DKL, DKM, DKN, DKO) -> DKP)) -> fun((DKL) -> fun((DKM) -> fun((DKN) -> fun((DKO) -> DKP)))).
curry4(Fun) ->
    fun(A) -> fun(B) -> fun(C) -> fun(D) -> Fun(A, B, C, D) end end end end.

-spec curry5(fun((DKR, DKS, DKT, DKU, DKV) -> DKW)) -> fun((DKR) -> fun((DKS) -> fun((DKT) -> fun((DKU) -> fun((DKV) -> DKW))))).
curry5(Fun) ->
    fun(A) ->
        fun(B) ->
            fun(C) -> fun(D) -> fun(E) -> Fun(A, B, C, D, E) end end end
        end
    end.

-spec curry6(fun((DKY, DKZ, DLA, DLB, DLC, DLD) -> DLE)) -> fun((DKY) -> fun((DKZ) -> fun((DLA) -> fun((DLB) -> fun((DLC) -> fun((DLD) -> DLE)))))).
curry6(Fun) ->
    fun(A) ->
        fun(B) ->
            fun(C) ->
                fun(D) -> fun(E) -> fun(F) -> Fun(A, B, C, D, E, F) end end end
            end
        end
    end.

-spec flip(fun((DLG, DLH) -> DLI)) -> fun((DLH, DLG) -> DLI).
flip(Fun) ->
    fun(B, A) -> Fun(A, B) end.

-spec identity(DLJ) -> DLJ.
identity(X) ->
    X.

-spec constant(DLK) -> fun((any()) -> DLK).
constant(Value) ->
    fun(_) -> Value end.

-spec tap(DLM, fun((DLM) -> any())) -> DLM.
tap(Arg, Effect) ->
    Effect(Arg),
    Arg.

-spec apply1(fun((DLO) -> DLP), DLO) -> DLP.
apply1(Fun, Arg1) ->
    Fun(Arg1).

-spec apply2(fun((DLQ, DLR) -> DLS), DLQ, DLR) -> DLS.
apply2(Fun, Arg1, Arg2) ->
    Fun(Arg1, Arg2).

-spec apply3(fun((DLT, DLU, DLV) -> DLW), DLT, DLU, DLV) -> DLW.
apply3(Fun, Arg1, Arg2, Arg3) ->
    Fun(Arg1, Arg2, Arg3).

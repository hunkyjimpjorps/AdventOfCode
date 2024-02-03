-module(gleam@function).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function]).

-export([compose/2, curry2/1, curry3/1, curry4/1, curry5/1, curry6/1, flip/1, identity/1, constant/1, tap/2, apply1/2, apply2/3, apply3/4]).

-spec compose(fun((DOO) -> DOP), fun((DOP) -> DOQ)) -> fun((DOO) -> DOQ).
compose(Fun1, Fun2) ->
    fun(A) -> Fun2(Fun1(A)) end.

-spec curry2(fun((DOR, DOS) -> DOT)) -> fun((DOR) -> fun((DOS) -> DOT)).
curry2(Fun) ->
    fun(A) -> fun(B) -> Fun(A, B) end end.

-spec curry3(fun((DOV, DOW, DOX) -> DOY)) -> fun((DOV) -> fun((DOW) -> fun((DOX) -> DOY))).
curry3(Fun) ->
    fun(A) -> fun(B) -> fun(C) -> Fun(A, B, C) end end end.

-spec curry4(fun((DPA, DPB, DPC, DPD) -> DPE)) -> fun((DPA) -> fun((DPB) -> fun((DPC) -> fun((DPD) -> DPE)))).
curry4(Fun) ->
    fun(A) -> fun(B) -> fun(C) -> fun(D) -> Fun(A, B, C, D) end end end end.

-spec curry5(fun((DPG, DPH, DPI, DPJ, DPK) -> DPL)) -> fun((DPG) -> fun((DPH) -> fun((DPI) -> fun((DPJ) -> fun((DPK) -> DPL))))).
curry5(Fun) ->
    fun(A) ->
        fun(B) ->
            fun(C) -> fun(D) -> fun(E) -> Fun(A, B, C, D, E) end end end
        end
    end.

-spec curry6(fun((DPN, DPO, DPP, DPQ, DPR, DPS) -> DPT)) -> fun((DPN) -> fun((DPO) -> fun((DPP) -> fun((DPQ) -> fun((DPR) -> fun((DPS) -> DPT)))))).
curry6(Fun) ->
    fun(A) ->
        fun(B) ->
            fun(C) ->
                fun(D) -> fun(E) -> fun(F) -> Fun(A, B, C, D, E, F) end end end
            end
        end
    end.

-spec flip(fun((DPV, DPW) -> DPX)) -> fun((DPW, DPV) -> DPX).
flip(Fun) ->
    fun(B, A) -> Fun(A, B) end.

-spec identity(DPY) -> DPY.
identity(X) ->
    X.

-spec constant(DPZ) -> fun((any()) -> DPZ).
constant(Value) ->
    fun(_) -> Value end.

-spec tap(DQB, fun((DQB) -> any())) -> DQB.
tap(Arg, Effect) ->
    Effect(Arg),
    Arg.

-spec apply1(fun((DQD) -> DQE), DQD) -> DQE.
apply1(Fun, Arg1) ->
    Fun(Arg1).

-spec apply2(fun((DQF, DQG) -> DQH), DQF, DQG) -> DQH.
apply2(Fun, Arg1, Arg2) ->
    Fun(Arg1, Arg2).

-spec apply3(fun((DQI, DQJ, DQK) -> DQL), DQI, DQJ, DQK) -> DQL.
apply3(Fun, Arg1, Arg2, Arg3) ->
    Fun(Arg1, Arg2, Arg3).

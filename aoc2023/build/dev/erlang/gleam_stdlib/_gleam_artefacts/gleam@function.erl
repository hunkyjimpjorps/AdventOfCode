-module(gleam@function).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch]).

-export([compose/2, curry2/1, curry3/1, curry4/1, curry5/1, curry6/1, flip/1, identity/1, constant/1, tap/2, apply1/2, apply2/3, apply3/4]).

-spec compose(fun((DFV) -> DFW), fun((DFW) -> DFX)) -> fun((DFV) -> DFX).
compose(Fun1, Fun2) ->
    fun(A) -> Fun2(Fun1(A)) end.

-spec curry2(fun((DFY, DFZ) -> DGA)) -> fun((DFY) -> fun((DFZ) -> DGA)).
curry2(Fun) ->
    fun(A) -> fun(B) -> Fun(A, B) end end.

-spec curry3(fun((DGC, DGD, DGE) -> DGF)) -> fun((DGC) -> fun((DGD) -> fun((DGE) -> DGF))).
curry3(Fun) ->
    fun(A) -> fun(B) -> fun(C) -> Fun(A, B, C) end end end.

-spec curry4(fun((DGH, DGI, DGJ, DGK) -> DGL)) -> fun((DGH) -> fun((DGI) -> fun((DGJ) -> fun((DGK) -> DGL)))).
curry4(Fun) ->
    fun(A) -> fun(B) -> fun(C) -> fun(D) -> Fun(A, B, C, D) end end end end.

-spec curry5(fun((DGN, DGO, DGP, DGQ, DGR) -> DGS)) -> fun((DGN) -> fun((DGO) -> fun((DGP) -> fun((DGQ) -> fun((DGR) -> DGS))))).
curry5(Fun) ->
    fun(A) ->
        fun(B) ->
            fun(C) -> fun(D) -> fun(E) -> Fun(A, B, C, D, E) end end end
        end
    end.

-spec curry6(fun((DGU, DGV, DGW, DGX, DGY, DGZ) -> DHA)) -> fun((DGU) -> fun((DGV) -> fun((DGW) -> fun((DGX) -> fun((DGY) -> fun((DGZ) -> DHA)))))).
curry6(Fun) ->
    fun(A) ->
        fun(B) ->
            fun(C) ->
                fun(D) -> fun(E) -> fun(F) -> Fun(A, B, C, D, E, F) end end end
            end
        end
    end.

-spec flip(fun((DHC, DHD) -> DHE)) -> fun((DHD, DHC) -> DHE).
flip(Fun) ->
    fun(B, A) -> Fun(A, B) end.

-spec identity(DHF) -> DHF.
identity(X) ->
    X.

-spec constant(DHG) -> fun((any()) -> DHG).
constant(Value) ->
    fun(_) -> Value end.

-spec tap(DHI, fun((DHI) -> any())) -> DHI.
tap(Arg, Effect) ->
    Effect(Arg),
    Arg.

-spec apply1(fun((DHK) -> DHL), DHK) -> DHL.
apply1(Fun, Arg1) ->
    Fun(Arg1).

-spec apply2(fun((DHM, DHN) -> DHO), DHM, DHN) -> DHO.
apply2(Fun, Arg1, Arg2) ->
    Fun(Arg1, Arg2).

-spec apply3(fun((DHP, DHQ, DHR) -> DHS), DHP, DHQ, DHR) -> DHS.
apply3(Fun, Arg1, Arg2, Arg3) ->
    Fun(Arg1, Arg2, Arg3).

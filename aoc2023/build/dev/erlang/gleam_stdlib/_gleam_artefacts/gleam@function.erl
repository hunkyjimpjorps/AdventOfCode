-module(gleam@function).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function]).

-export([compose/2, curry2/1, curry3/1, curry4/1, curry5/1, curry6/1, flip/1, identity/1, constant/1, tap/2, apply1/2, apply2/3, apply3/4]).

-spec compose(fun((ENH) -> ENI), fun((ENI) -> ENJ)) -> fun((ENH) -> ENJ).
compose(Fun1, Fun2) ->
    fun(A) -> Fun2(Fun1(A)) end.

-spec curry2(fun((ENK, ENL) -> ENM)) -> fun((ENK) -> fun((ENL) -> ENM)).
curry2(Fun) ->
    fun(A) -> fun(B) -> Fun(A, B) end end.

-spec curry3(fun((ENO, ENP, ENQ) -> ENR)) -> fun((ENO) -> fun((ENP) -> fun((ENQ) -> ENR))).
curry3(Fun) ->
    fun(A) -> fun(B) -> fun(C) -> Fun(A, B, C) end end end.

-spec curry4(fun((ENT, ENU, ENV, ENW) -> ENX)) -> fun((ENT) -> fun((ENU) -> fun((ENV) -> fun((ENW) -> ENX)))).
curry4(Fun) ->
    fun(A) -> fun(B) -> fun(C) -> fun(D) -> Fun(A, B, C, D) end end end end.

-spec curry5(fun((ENZ, EOA, EOB, EOC, EOD) -> EOE)) -> fun((ENZ) -> fun((EOA) -> fun((EOB) -> fun((EOC) -> fun((EOD) -> EOE))))).
curry5(Fun) ->
    fun(A) ->
        fun(B) ->
            fun(C) -> fun(D) -> fun(E) -> Fun(A, B, C, D, E) end end end
        end
    end.

-spec curry6(fun((EOG, EOH, EOI, EOJ, EOK, EOL) -> EOM)) -> fun((EOG) -> fun((EOH) -> fun((EOI) -> fun((EOJ) -> fun((EOK) -> fun((EOL) -> EOM)))))).
curry6(Fun) ->
    fun(A) ->
        fun(B) ->
            fun(C) ->
                fun(D) -> fun(E) -> fun(F) -> Fun(A, B, C, D, E, F) end end end
            end
        end
    end.

-spec flip(fun((EOO, EOP) -> EOQ)) -> fun((EOP, EOO) -> EOQ).
flip(Fun) ->
    fun(B, A) -> Fun(A, B) end.

-spec identity(EOR) -> EOR.
identity(X) ->
    X.

-spec constant(EOS) -> fun((any()) -> EOS).
constant(Value) ->
    fun(_) -> Value end.

-spec tap(EOU, fun((EOU) -> any())) -> EOU.
tap(Arg, Effect) ->
    Effect(Arg),
    Arg.

-spec apply1(fun((EOW) -> EOX), EOW) -> EOX.
apply1(Fun, Arg1) ->
    Fun(Arg1).

-spec apply2(fun((EOY, EOZ) -> EPA), EOY, EOZ) -> EPA.
apply2(Fun, Arg1, Arg2) ->
    Fun(Arg1, Arg2).

-spec apply3(fun((EPB, EPC, EPD) -> EPE), EPB, EPC, EPD) -> EPE.
apply3(Fun, Arg1, Arg2, Arg3) ->
    Fun(Arg1, Arg2, Arg3).

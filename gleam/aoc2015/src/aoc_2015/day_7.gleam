import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/string
import rememo/ets/memo

type Wire {
  Into(from: String)
  DirectInto(val: Int)
  And(first: String, second: String)
  Or(first: String, second: String)
  RShift(first: String, by: Int)
  LShift(first: String, by: Int)
  Not(first: String)
}

fn parse_instruction(input: String) {
  case string.split(input, " ") {
    [from, "->", gate] -> {
      case int.parse(from) {
        Ok(n) -> #(gate, DirectInto(n))
        Error(_) -> #(gate, Into(from))
      }
    }
    [first, "AND", second, "->", gate] -> #(gate, And(first, second))
    [first, "OR", second, "->", gate] -> #(gate, Or(first, second))
    [first, "RSHIFT", by, "->", gate] -> #(gate, RShift(first, assert_int(by)))
    [first, "LSHIFT", by, "->", gate] -> #(gate, LShift(first, assert_int(by)))
    ["NOT", first, "->", gate] -> #(gate, Not(first))
    _ -> panic as "bad instruction"
  }
}

fn trace(current: String, wires: Dict(String, Wire), c) {
  use <- memo.memoize(c, current)
  let assert Ok(wire) = dict.get(wires, current)

  case wire {
    DirectInto(n) -> n
    Into(from) -> trace(from, wires, c)
    And(first, second) -> {
      case int.parse(first) {
        Ok(n) -> int.bitwise_and(n, trace(second, wires, c))
        Error(_) ->
          int.bitwise_and(trace(first, wires, c), trace(second, wires, c))
      }
    }
    Or(first, second) ->
      int.bitwise_or(trace(first, wires, c), trace(second, wires, c))
    RShift(first, by) -> int.bitwise_shift_right(trace(first, wires, c), by)
    LShift(first, by) -> int.bitwise_shift_left(trace(first, wires, c), by)
    Not(first) -> int.bitwise_not(trace(first, wires, c))
  }
}

fn make_wires(input: String) {
  input
  |> string.split("\n")
  |> list.map(parse_instruction)
  |> dict.from_list
}

pub fn pt_1(input: String) {
  use c <- memo.create()
  trace("a", make_wires(input), c)
}

pub fn pt_2(input: String) {
  let wires = make_wires(input)
  let b = pt_1(input)
  use c <- memo.create()
  dict.insert(wires, "b", DirectInto(b))
  |> trace("a", _, c)
}

fn assert_int(str: String) -> Int {
  let assert Ok(n) = int.parse(str)
  n
}

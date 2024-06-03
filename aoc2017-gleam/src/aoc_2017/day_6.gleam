import gary.{type ErlangArray}
import gary/array
import gleam/bool
import gleam/int
import gleam/list
import gleam/result
import gleam/set.{type Set}
import gleam/string

pub fn parse(input) -> ErlangArray(Int) {
  input
  |> string.split("\t")
  |> list.map(int.parse)
  |> result.values()
  |> array.from_list(default: -1)
  |> array.make_fixed()
}

pub fn pt_1(input: ErlangArray(Int)) {
  check_cycle(input, set.from_list([input]), 1).1
}

pub fn pt_2(input: ErlangArray(Int)) {
  let #(target, cycle) = check_cycle(input, set.from_list([input]), 1)
  cycle - check_cycle(input, set.from_list([input, target]), 1).1
}

fn get_max(array: ErlangArray(Int)) -> #(Int, Int) {
  use index, value, max <- array.fold(over: array, from: #(-1, -1))
  case value > max.1 {
    True -> #(index, value)
    False -> max
  }
}

fn redistribute(
  array: ErlangArray(Int),
  pointer: Int,
  remaining: Int,
) -> ErlangArray(Int) {
  use <- bool.guard(remaining == 0, array)
  case array.get(from: array, at: pointer) {
    Error(_) -> redistribute(array, 0, remaining)
    Ok(n) -> {
      let assert Ok(updated_array) =
        array.set(into: array, at: pointer, put: n + 1)
      redistribute(updated_array, pointer + 1, remaining - 1)
    }
  }
}

fn check_cycle(
  current: ErlangArray(Int),
  cache: Set(ErlangArray(Int)),
  cycle: Int,
) -> #(ErlangArray(Int), Int) {
  let #(index, to_redistribute) = current |> get_max
  let assert Ok(zeroed) = array.set(into: current, at: index, put: 0)
  let next = redistribute(zeroed, index + 1, to_redistribute)

  case set.contains(cache, next) {
    True -> #(next, cycle)
    False -> check_cycle(next, set.insert(cache, next), cycle + 1)
  }
}

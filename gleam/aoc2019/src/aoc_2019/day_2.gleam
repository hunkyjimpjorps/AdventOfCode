import gary.{type ErlangArray}
import gary/array.{type ArrayError}
import gleam/bool
import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub fn parse(input: String) -> ErlangArray(Int) {
  input
  |> string.split(",")
  |> list.map(int.parse)
  |> result.values()
  |> array.from_list(default: -1)
  |> array.make_fixed()
}

pub fn pt_1(input: ErlangArray(Int)) -> Int {
  let assert Ok(result) =
    input
    |> edit_starting_intcodes(12, 2)
    |> run_intcode(0)

  result
}

pub fn pt_2(input: ErlangArray(Int)) -> Int {
  let assert [result] = {
    use noun <- list.flat_map(list.range(0, 99))
    use verb <- list.filter_map(list.range(0, 99))
    let result = input |> edit_starting_intcodes(noun, verb) |> run_intcode(0)
    case result == Ok(19_690_720) {
      True -> Ok(100 * noun + verb)
      False -> Error(Nil)
    }
  }

  result
}

fn run_intcode(
  intcode: ErlangArray(Int),
  pointer: Int,
) -> Result(Int, ArrayError) {
  let assert Ok(op_code) = array.get(intcode, pointer)
  let op = get_op(op_code)

  use <- bool.guard(result.is_error(op), array.get(intcode, 0))
  let assert Ok(position_1) = array.get(intcode, pointer + 1)
  let assert Ok(position_2) = array.get(intcode, pointer + 2)
  let assert Ok(position_3) = array.get(intcode, pointer + 3)

  let assert Ok(value_1) = array.get(intcode, position_1)
  let assert Ok(value_2) = array.get(intcode, position_2)

  let assert Ok(f) = op
  let new_value = f(value_1, value_2)
  let assert Ok(updated_intcode) = array.set(intcode, position_3, new_value)
  run_intcode(updated_intcode, pointer + 4)
}

fn edit_starting_intcodes(
  intcodes: ErlangArray(Int),
  new_code_1: Int,
  new_code_2: Int,
) -> ErlangArray(Int) {
  let assert Ok(updated) =
    intcodes
    |> array.set(at: 1, put: new_code_1)
    |> result.try(array.set(into: _, at: 2, put: new_code_2))
  updated
}

fn get_op(code: Int) -> Result(fn(Int, Int) -> Int, Nil) {
  case code {
    1 -> Ok(int.add)
    2 -> Ok(int.multiply)
    99 -> Error(Nil)
    _ -> panic as "bad opcode"
  }
}

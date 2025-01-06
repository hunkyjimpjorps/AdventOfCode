import gary.{type ErlangArray}
import gary/array
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import my_utils/intcode.{Computer}

pub fn parse(input: String) -> ErlangArray(Int) {
  input
  |> string.split(",")
  |> list.map(int.parse)
  |> result.values()
  |> array.from_list(default: -1)
  |> array.make_fixed()
}

pub fn pt_1(input: ErlangArray(Int)) {
  input
  |> edit_starting_intcodes(12, 2)
  |> Computer(intcode: _, inputs: [], outputs: [])
  |> intcode.run_intcode(starting_at: 0)
  |> intcode.read_position(0)
}

pub fn pt_2(input: ErlangArray(Int)) {
  use noun <- list.find_map(list.range(0, 99))
  use verb <- list.find_map(list.range(0, 99))
  let result =
    input
    |> edit_starting_intcodes(noun, verb)
    |> Computer(intcode: _, inputs: [], outputs: [])
    |> intcode.run_intcode(starting_at: 0)
    |> intcode.read_position(0)
  case result == Ok(19_690_720) {
    True -> Ok(noun * 100 + verb)
    False -> Error(Nil)
  }
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

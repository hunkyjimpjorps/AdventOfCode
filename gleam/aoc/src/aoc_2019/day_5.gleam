import gary.{type ErlangArray}
import gleam/list
import my_utils/intcode.{Computer}

pub fn parse(input: String) -> ErlangArray(Int) {
  intcode.parse_intcode(input)
}

pub fn pt_1(input: ErlangArray(Int)) {
  input
  |> Computer(intcode: _, inputs: [1], outputs: [], pointer: 0)
  |> intcode.run_intcode()
  |> intcode.read_outputs
  |> list.first
}

pub fn pt_2(input: ErlangArray(Int)) {
  input
  |> Computer(intcode: _, inputs: [5], outputs: [], pointer: 0)
  |> intcode.run_intcode()
  |> intcode.read_outputs
  |> list.first
}

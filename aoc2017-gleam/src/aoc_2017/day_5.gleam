import gary.{type ErlangArray}
import gary/array
import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub fn parse(input: String) -> ErlangArray(Int) {
  input
  |> string.split("\n")
  |> list.map(int.parse)
  |> result.values()
  |> array.from_list(default: 0)
  |> array.make_fixed()
}

pub fn pt_1(input: ErlangArray(Int)) {
  next_step(input, 0, 0, part: 1)
}

pub fn pt_2(input: ErlangArray(Int)) {
  next_step(input, 0, 0, part: 2)
}

fn next_step(
  instructions: ErlangArray(Int),
  pointer: Int,
  step: Int,
  part part: Int,
) {
  case array.get(from: instructions, at: pointer) {
    Ok(distance) -> {
      let delta = delta(distance, part)
      let assert Ok(updated_instructions) =
        array.set(instructions, at: pointer, put: distance + delta)
      next_step(updated_instructions, pointer + distance, step + 1, part)
    }
    Error(_) -> step
  }
}

fn delta(d: Int, part: Int) {
  case part, d {
    1, _ -> 1
    _, n if n < 3 -> 1
    _, _ -> -1
  }
}

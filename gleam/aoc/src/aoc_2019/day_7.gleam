import gleam/list
import gleam/result
import my_utils/intcode.{type Computer}

pub fn parse(input: String) -> Computer {
  input
  |> intcode.parse_intcode
  |> intcode.initialize_computer
}

pub fn pt_1(input: Computer) {
  // list.range(0, 4)
  // |> list.permutations
  // |>
  list.map([[0, 1, 2, 3, 4]], fn(permutation) {
    use phase, signal <- list.fold(permutation, 0)
    input
    |> intcode.set_inputs([phase, signal, 0, 0, 0, 0])
    |> intcode.run_intcode
    |> intcode.read_outputs
    |> list.first
    |> result.unwrap(0)
  })
}

pub fn pt_2(input: Computer) {
  todo as "part 2 not implemented"
}

import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/result
import gleam/string

type Pipes =
  Dict(Int, List(Int))

pub fn parse(input: String) -> Pipes {
  {
    use row <- list.map(string.split(input, "\n"))
    let assert Ok(#(from, to)) = string.split_once(row, " <-> ")

    let assert Ok(from) = int.parse(from)
    let to = to |> string.split(", ") |> list.map(int.parse) |> result.values

    #(from, to)
  }
  |> dict.from_list
}

pub fn pt_1(input: Pipes) {
  input
}

pub fn pt_2(input: Pipes) {
  todo as "part 2 not implemented"
}

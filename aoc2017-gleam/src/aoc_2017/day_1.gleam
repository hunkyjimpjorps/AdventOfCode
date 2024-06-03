import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub fn parse(input: String) {
  input
  |> string.to_graphemes()
  |> list.map(int.parse)
  |> result.values()
}

pub fn pt_1(input: List(Int)) {
  pair_by(numbers: input, considering: 1)
}

pub fn pt_2(input: List(Int)) {
  pair_by(numbers: input, considering: list.length(input) / 2)
}

fn find_neighbor_matches(number_pairs: List(#(Int, Int))) {
  case number_pairs {
    [] -> 0
    [#(a, b), ..rest] if a == b -> a + find_neighbor_matches(rest)
    [_, ..rest] -> find_neighbor_matches(rest)
  }
}

fn pair_by(numbers xs: List(Int), considering by: Int) {
  list.zip(xs, list.append(list.drop(xs, by), list.take(xs, by)))
  |> find_neighbor_matches()
}

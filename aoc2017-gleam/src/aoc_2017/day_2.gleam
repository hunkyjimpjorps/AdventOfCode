import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub fn parse(input: String) {
  use row <- list.map(string.split(input, "\n"))
  use val <- list.map(string.split(row, "\t"))
  let assert Ok(n) = int.parse(val)
  n
}

pub fn pt_1(input: List(List(Int))) {
  use acc, row <- list.fold(input, 0)
  acc + max(row) - min(row)
}

pub fn pt_2(input: List(List(Int))) {
  use acc, row <- list.fold(input, 0)
  let assert [val] =
    row |> list.combination_pairs() |> list.map(test_pair) |> result.values()
  acc + val
}

fn max(xs) {
  let assert Ok(result) = list.reduce(xs, int.max)
  result
}

fn min(xs) {
  let assert Ok(result) = list.reduce(xs, int.min)
  result
}

fn test_pair(tup) {
  case tup {
    #(a, b) if a > b -> check_divisibility(a, b)
    #(b, a) -> check_divisibility(a, b)
  }
}

fn check_divisibility(a, b) {
  case a % b {
    0 -> Ok(a / b)
    _ -> Error(Nil)
  }
}

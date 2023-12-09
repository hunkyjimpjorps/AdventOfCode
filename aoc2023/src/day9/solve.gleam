import adglent.{First, Second}
import gleam/io
import gleam/list
import gleam/string
import gleam/int

fn parse(input: String, backwards backwards: Bool) -> List(List(Int)) {
  use line <- list.map(string.split(input, "\n"))
  use n_str <- list.map(maybe_backwards(string.split(line, " "), backwards))
  let assert Ok(n) = int.parse(n_str)
  n
}

fn maybe_backwards(xs: List(a), backwards: Bool) -> List(a) {
  case backwards {
    False -> list.reverse(xs)
    True -> xs
  }
}

fn is_constant(ns: List(Int)) -> Bool {
  case list.unique(ns) {
    [_] -> True
    _ -> False
  }
}

fn take_derivative(ns: List(Int)) -> List(Int) {
  ns
  |> list.window_by_2
  |> list.map(fn(tup) { tup.0 - tup.1 })
}

fn extrapolate(ns: List(Int)) {
  case is_constant(ns), ns {
    True, [n, ..] -> n
    False, [n, ..] -> n + extrapolate(take_derivative(ns))
  }
}

fn part(input: String, backwards backwards: Bool) {
  input
  |> parse(backwards: backwards)
  |> list.fold(0, fn(acc, ns) { extrapolate(ns) + acc })
  |> string.inspect
}

pub fn part1(input: String) {
  part(input, backwards: False)
}

pub fn part2(input: String) {
  part(input, backwards: True)
}

pub fn main() {
  let assert Ok(part) = adglent.get_part()
  let assert Ok(input) = adglent.get_input("9")
  case part {
    First ->
      part1(input)
      |> adglent.inspect
      |> io.println
    Second ->
      part2(input)
      |> adglent.inspect
      |> io.println
  }
}

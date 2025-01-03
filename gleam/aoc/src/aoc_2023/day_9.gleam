import gleam/list
import gleam/string
import my_utils/to

fn parse(input: String, backwards backwards: Bool) -> List(List(Int)) {
  use line <- list.map(string.split(input, "\n"))
  use n_str <- list.map(maybe_backwards(string.split(line, " "), backwards))
  to.int(n_str)
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
    _, _ -> panic as "list empty when it shouldn't be"
  }
}

fn solve(input: String, backwards backwards: Bool) {
  input
  |> parse(backwards: backwards)
  |> list.fold(0, fn(acc, ns) { extrapolate(ns) + acc })
  |> string.inspect
}

pub fn pt_1(input: String) {
  solve(input, backwards: False)
}

pub fn pt_2(input: String) {
  solve(input, backwards: True)
}

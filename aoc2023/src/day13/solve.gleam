import adglent.{First, Second}
import gleam/io
import gleam/list
import gleam/string
import gleam/bool

type SymmetryType {
  Horizontal(Int)
  Vertical(Int)
}

fn is_symmetric(xss: List(List(a)), errs: Int) {
  let assert [left, ..right] = xss
  do_is_symmetric([left], right, errs)
}

fn do_is_symmetric(
  left: List(List(a)),
  right: List(List(a)),
  errors: Int,
) -> Result(Int, Nil) {
  use <- bool.guard(list.is_empty(right), Error(Nil))
  let assert [h, ..t] = right
  let found_errors =
    list.zip(list.flatten(left), list.flatten(right))
    |> list.filter(fn(tup) { tup.1 != tup.0 })
    |> list.length
  case found_errors == errors {
    True -> Ok(list.length(left))
    False -> do_is_symmetric([h, ..left], t, errors)
  }
}

fn get_symmetry_type(xss: List(List(String)), errors: Int) {
  case is_symmetric(xss, errors) {
    Ok(n) -> Horizontal(n)
    _ -> {
      let assert Ok(n) = is_symmetric(list.transpose(xss), errors)
      Vertical(n)
    }
  }
}

fn summarize_notes(symmetries: List(SymmetryType)) {
  use acc, note <- list.fold(symmetries, 0)
  case note {
    Horizontal(n) -> 100 * n
    Vertical(n) -> n
  } + acc
}

fn solve(input: String, errors: Int) {
  input
  |> string.split("\n\n")
  |> list.map(fn(strs) {
    strs
    |> string.split("\n")
    |> list.map(string.to_graphemes)
    |> get_symmetry_type(errors)
  })
  |> summarize_notes
  |> string.inspect
}

pub fn part1(input: String) {
  solve(input, 0)
}

pub fn part2(input: String) {
  solve(input, 1)
}

pub fn main() {
  let assert Ok(part) = adglent.get_part()
  let assert Ok(input) = adglent.get_input("13")
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

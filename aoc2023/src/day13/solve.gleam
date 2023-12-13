import adglent.{First, Second}
import gleam/io
import gleam/list
import gleam/string
import gleam/result

type SymmetryType {
  Horizontal(Int)
  Vertical(Int)
}

fn is_symmetric(xs: List(List(a)), errors: Int, index: Int) -> Result(Int, Nil) {
  case list.split(xs, index) {
    #(_, []) -> Error(Nil)
    #(ls, rs) -> {
      let zipped = list.zip(list.flatten(list.reverse(ls)), list.flatten(rs))
      let found_errors =
        zipped
        |> list.filter(fn(tup) { tup.1 != tup.0 })
        |> list.length
      case found_errors == errors {
        True -> Ok(index)
        False -> is_symmetric(xs, errors, index + 1)
      }
    }
  }
}

fn get_symmetry_type(xs: List(List(String)), errors: Int) {
  result.or(
    xs
    |> is_symmetric(errors, 1)
    |> result.map(Horizontal(_)),
    xs
    |> list.transpose()
    |> is_symmetric(errors, 1)
    |> result.map(Vertical(_)),
  )
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
  |> result.values
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

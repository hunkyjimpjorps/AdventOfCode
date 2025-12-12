import gleam/int
import gleam/list
import gleam/regexp
import gleam/string
import my_utils/to

pub fn parse(input: String) -> List(List(Int)) {
  let assert [_, _, _, _, _, _, regions] = string.split(input, "\n\n")
  let assert Ok(re) = regexp.from_string("x|: | ")
  regions
  |> string.split("\n")
  |> list.map(fn(str) { str |> regexp.split(re, _) |> list.map(to.int) })
}

pub fn pt_1(input: List(List(Int))) {
  use region <- list.count(input)
  let assert [w, h, ..presents] = region
  w * h >= int.sum(presents) * 9
}

pub fn pt_2(_input: List(List(Int))) {
  "🎅"
}

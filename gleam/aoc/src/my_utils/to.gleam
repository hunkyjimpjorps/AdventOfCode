//// Utility functions to convert input strings to common Advent of Code data types, 
//// like comma-delimted numeric strings into lists of integers

import gleam/int
import gleam/list
import gleam/string
import my_utils/xy.{type XY, XY}
import tote/bag

pub fn int(str: String) -> Int {
  let assert Ok(n) = int.parse(str)
  n
}

pub fn delimited_list(
  str: String,
  split_on delimiter: String,
  using f: fn(String) -> a,
) -> List(a) {
  str |> string.split(delimiter) |> list.map(f)
}

pub fn lists_of_graphemes(input: String) {
  delimited_list(input, "\n", string.to_graphemes)
}

pub fn ints(str: String, split_on delimiter: String) -> List(Int) {
  delimited_list(str, delimiter, int)
}

pub fn list_of_xys(input: String, split_on delimeter: String) -> List(XY) {
  delimited_list(input, "\n", fn(line) {
    let assert Ok(#(x, y)) = string.split_once(line, delimeter)
    XY(int(x), int(y))
  })
}

pub fn frequencies(xs: List(a)) -> List(#(a, Int)) {
  xs |> bag.from_list |> bag.to_list
}

pub fn range(xs: List(Int)) {
  let assert [first, ..rest] = xs

  list.fold(rest, #(first, first), fn(acc, x) {
    let min = int.min(x, acc.0)
    let max = int.max(x, acc.1)
    #(min, max)
  })
}

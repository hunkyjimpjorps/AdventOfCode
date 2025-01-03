//// Utility functions to convert input strings to common Advent of Code data types, 
//// like comma-delimted numeric strings into lists of integers

import gleam/int
import gleam/list
import gleam/string

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

pub fn ints(str: String, split_on delimiter: String) -> List(Int) {
  delimited_list(str, delimiter, int)
}

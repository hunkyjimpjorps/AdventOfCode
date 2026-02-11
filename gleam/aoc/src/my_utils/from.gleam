//// Utilities for processing entire input files with typical formats
//// 

import gleam/dict.{type Dict}
import gleam/list
import gleam/result
import gleam/string
import my_utils/to

pub fn list_of_list_of_ints(input: String, delimiter: String) -> List(List(Int)) {
  input
  |> string.split("\n")
  |> list.map(to.ints(_, delimiter))
}

pub fn grid(
  input: String,
  constructor: fn(Int, Int) -> a,
  parser: fn(String) -> b,
) -> Dict(a, b) {
  {
    use row, r <- list.index_map(string.split(input, "\n"))
    use col, c <- list.index_map(string.to_graphemes(row))
    #(constructor(r, c), parser(col))
  }
  |> list.flatten
  |> dict.from_list
}

pub fn try_grid(
  input: String,
  constructor: fn(Int, Int) -> a,
  parser: fn(String) -> Result(b, c),
) -> Dict(a, b) {
  {
    use row, r <- list.index_map(string.split(input, "\n"))
    use col, c <- list.index_map(string.to_graphemes(row))
    case parser(col) {
      Ok(result) -> Ok(#(constructor(r, c), result))
      Error(_) -> Error(Nil)
    }
  }
  |> list.flatten
  |> result.values
  |> dict.from_list
}

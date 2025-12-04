//// Utilities for processing entire input files with typical formats
//// 

import gleam/dict.{type Dict}
import gleam/list
import gleam/result
import gleam/set.{type Set}
import gleam/string
import my_utils/to
import my_utils/xy.{type XY, XY}

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
  parser: fn(String) -> Result(a, b),
) -> Dict(XY, a) {
  {
    use row, r <- list.index_map(string.split(input, "\n"))
    use col, c <- list.index_map(string.to_graphemes(row))
    case parser(col) {
      Ok(result) -> Ok(#(XY(r, c), result))
      Error(_) -> Error(Nil)
    }
  }
  |> list.flatten
  |> result.values
  |> dict.from_list
}

pub fn try_point_set(
  input: String,
  parser: fn(String) -> Bool,
) -> Set(XY) {
  {
    use row, r <- list.index_map(string.split(input, "\n"))
    use col, c <- list.index_map(string.to_graphemes(row))
    case parser(col) {
      True -> Ok(XY(r, c))
      False -> Error(Nil)
    }
  }
  |> list.flatten
  |> result.values
  |> set.from_list
}

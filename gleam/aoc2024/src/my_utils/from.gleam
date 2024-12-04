//// Utilities for processing entire input files with typical formats
//// 

import gleam/dict.{type Dict}
import gleam/list
import gleam/string
import my_utils/coord.{type Coord, Coord}
import my_utils/to

pub fn list_of_list_of_ints(input: String, delimiter: String) -> List(List(Int)) {
  input
  |> string.split("\n")
  |> list.map(to.ints(_, delimiter))
}

pub fn grid(input: String, parser: fn(String) -> a) -> Dict(Coord, a) {
  {
    use row, r <- list.index_map(string.split(input, "\n"))
    use col, c <- list.index_map(string.to_graphemes(row))
    #(Coord(r, c), parser(col))
  }
  |> list.flatten
  |> dict.from_list
}

//// Utilities for processing entire input files with typical formats
//// 

import gleam/list
import gleam/string
import my_utils/to

pub fn list_of_list_of_ints(input: String, delimiter: String) -> List(List(Int)) {
  input
  |> string.split("\n")
  |> list.map(to.ints(_, delimiter))
}

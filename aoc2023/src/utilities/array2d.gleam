import gleam/list
import gleam/dict.{type Dict}
import gleam/string

pub type Posn {
  Posn(x: Int, y: Int)
}

pub type Array2D(a) =
  Dict(Posn, a)

pub fn to_2d_array(xss: List(List(a))) -> Array2D(a) {
  {
    use x, row <- list.index_map(xss)
    use y, cell <- list.index_map(row)
    #(Posn(x, y), cell)
  }
  |> list.flatten
  |> dict.from_list
}

pub fn parse_grid(str: String) -> Array2D(String) {
  str
  |> string.split("\n")
  |> list.map(string.to_graphemes)
  |> to_2d_array
}

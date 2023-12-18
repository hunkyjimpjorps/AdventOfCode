import gleam/list
import gleam/dict.{type Dict}
import gleam/string

pub type Posn {
  Posn(r: Int, c: Int)
}

pub type Array2D(a) =
  Dict(Posn, a)

pub fn add_posns(p1: Posn, p2: Posn) -> Posn {
  case p1, p2 {
    Posn(r1, c1), Posn(r2, c2) -> Posn(r1 + r2, c1 + c2)
  }
}

pub fn to_2d_array(xss: List(List(a))) -> Array2D(a) {
  {
    use r, row <- list.index_map(xss)
    use c, cell <- list.index_map(row)
    #(Posn(r, c), cell)
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

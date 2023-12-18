import gleam/list
import gleam/dict.{type Dict}
import gleam/string
import gleam/int

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

pub fn to_2d_intarray(xss: List(List(String))) -> Array2D(Int) {
  {
    use r, row <- list.index_map(xss)
    use c, cell <- list.index_map(row)
    let assert Ok(n) = int.parse(cell)
    #(Posn(r, c), n)
  }
  |> list.flatten
  |> dict.from_list
}

pub fn to_list_of_lists(str: String) -> List(List(String)) {
  str
  |> string.split("\n")
  |> list.map(string.to_graphemes)
}

pub fn parse_grid(str: String) -> Array2D(String) {
  str
  |> to_list_of_lists
  |> to_2d_array
}

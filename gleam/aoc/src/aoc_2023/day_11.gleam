import gleam/int
import gleam/list
import gleam/string
import my_utils/xy.{type XY, XY}

fn find_empty(grid: List(List(String))) {
  use acc, row, r <- list.index_fold(grid, [])
  case list.unique(row) {
    ["."] -> [r, ..acc]
    _ -> acc
  }
}

fn count_prior_empty_ranks(rank: Int, empty_ranks: List(Int)) -> Int {
  empty_ranks
  |> list.drop_while(fn(r_empty) { r_empty > rank })
  |> list.length
}

fn parse_with_expansion(input: String, expansion: Int) -> List(XY) {
  let add = expansion - 1
  let grid =
    input
    |> string.split("\n")
    |> list.map(string.to_graphemes)

  let empty_row_list = find_empty(grid)
  let empty_col_list = find_empty(list.transpose(grid))

  {
    use row, r <- list.index_map(grid)
    use acc, cell, c <- list.index_fold(over: row, from: [])

    let p = XY(r, c)
    let empty_r = count_prior_empty_ranks(r, empty_row_list)
    let empty_c = count_prior_empty_ranks(c, empty_col_list)
    case cell {
      "#" -> [XY(p.x + empty_r * add, p.y + empty_c * add), ..acc]
      _empty -> acc
    }
  }
  |> list.flatten()
}

fn all_distances(stars: List(XY)) -> Int {
  use acc, pair <- list.fold(list.combination_pairs(stars), 0)
  let #(s1, s2) = pair
  acc + int.absolute_value(s1.x - s2.x) + int.absolute_value(s1.y - s2.y)
}

fn find_distances(input: String, expand_by: Int) {
  input
  |> parse_with_expansion(expand_by)
  |> all_distances
}

pub fn pt_1(input: String) {
  find_distances(input, 2)
}

pub fn pt_2(input: String) {
  find_distances(input, 1_000_000)
}

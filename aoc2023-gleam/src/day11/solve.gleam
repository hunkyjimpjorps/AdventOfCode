import adglent.{First, Second}
import gleam/io
import gleam/int
import gleam/string
import gleam/list

type Posn {
  Posn(x: Int, y: Int)
}

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

fn parse_with_expansion(input: String, expansion: Int) -> List(Posn) {
  let add = expansion - 1
  let grid =
    input
    |> string.split("\n")
    |> list.map(string.to_graphemes)

  let empty_row_list = find_empty(grid)
  let empty_col_list = find_empty(list.transpose(grid))

  {
    use r, row <- list.index_map(grid)
    use acc, cell, c <- list.index_fold(over: row, from: [])

    let p = Posn(r, c)
    let empty_r = count_prior_empty_ranks(r, empty_row_list)
    let empty_c = count_prior_empty_ranks(c, empty_col_list)
    case cell {
      "#" -> [Posn(p.x + empty_r * add, p.y + empty_c * add), ..acc]
      _empty -> acc
    }
  }
  |> list.flatten()
}

fn all_distances(stars: List(Posn)) -> Int {
  use acc, pair <- list.fold(list.combination_pairs(stars), 0)
  let #(s1, s2) = pair
  acc + int.absolute_value(s1.x - s2.x) + int.absolute_value(s1.y - s2.y)
}

fn find_distances(input: String, expand_by: Int) -> String {
  input
  |> parse_with_expansion(expand_by)
  |> all_distances
  |> string.inspect
}

pub fn part1(input: String) {
  find_distances(input, 2)
}

pub fn part2(input: String) {
  find_distances(input, 1_000_000)
}

pub fn main() {
  let assert Ok(part) = adglent.get_part()
  let assert Ok(input) = adglent.get_input("11")
  case part {
    First ->
      part1(input)
      |> adglent.inspect
      |> io.println
    Second ->
      part2(input)
      |> adglent.inspect
      |> io.println
  }
}

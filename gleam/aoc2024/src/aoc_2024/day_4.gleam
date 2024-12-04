import gleam/bool
import gleam/dict.{type Dict}
import gleam/list
import gleam/result
import gleam/string
import my_utils/coord.{type Coord, Coord}
import my_utils/from

pub type Grid =
  Dict(Coord, String)

const max = 140

pub fn parse(input: String) -> Grid {
  from.grid(input, fn(c) { c })
}

fn count_words(grid: Grid, word: String, coord: Coord, acc: Int) -> Int {
  use <- bool.guard(coord.r == max, acc)
  use <- bool.lazy_guard(coord.c == max, fn() {
    count_words(grid, word, coord.next_row(coord), acc)
  })

  let found =
    coord.eight_directions
    |> list.filter_map(scan_for_word(grid, word, coord, _))
    |> list.length
  count_words(grid, word, coord.next_col(coord), acc + found)
}

fn scan_for_word(grid: Grid, word: String, coord: Coord, dir: Coord) {
  case string.pop_grapheme(word), dict.get(grid, coord) {
    Ok(#(first, "")), Ok(v) if first == v -> Ok(Nil)
    Ok(#(first, rest)), Ok(v) if first == v ->
      scan_for_word(grid, rest, coord.go(coord, dir), dir)
    _, _ -> Error(Nil)
  }
}

pub fn pt_1(input: Grid) {
  count_words(input, "XMAS", coord.origin, 0)
}

fn find_x_mas(grid: Grid, coord: Coord, acc: Int) -> Int {
  use <- bool.guard(coord.r == max, acc)
  use <- bool.lazy_guard(coord.c == max, fn() {
    find_x_mas(grid, coord.next_row(coord), acc)
  })

  let found = case dict.get(grid, coord) {
    Ok("A") -> live_mas(grid, coord)
    _ -> 0
  }
  find_x_mas(grid, coord.next_col(coord), acc + found)
}

fn live_mas(grid: Grid, coord: Coord) {
  let found =
    [Coord(-1, -1), Coord(1, 1), Coord(-1, 1), Coord(1, -1)]
    |> list.map(fn(dir) { dict.get(grid, coord.go(coord, dir)) })
    |> result.values()
    |> string.join("")

  case found {
    "MSMS" | "MSSM" | "SMSM" | "SMMS" -> 1
    _ -> 0
  }
}

pub fn pt_2(input: Grid) {
  find_x_mas(input, coord.origin, 0)
}

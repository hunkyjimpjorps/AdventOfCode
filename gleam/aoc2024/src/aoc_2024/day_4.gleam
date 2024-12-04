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

fn count_xmases(grid: Grid, coord: Coord, acc: Int) -> Int {
  use <- bool.guard(coord.r == max, acc)
  use <- bool.lazy_guard(coord.c == max, fn() {
    count_xmases(grid, coord.next_row(coord), acc)
  })
  case dict.get(grid, coord) {
    Ok("X") ->
      list.fold(coord.eight_directions, acc, fn(found, dir) {
        found + scan_for_word(grid, "MAS", coord.go(coord, dir), dir)
      })
    _ -> acc
  }
  |> count_xmases(grid, coord.next_col(coord), _)
}

fn scan_for_word(grid: Grid, word: String, coord: Coord, dir: Coord) {
  case string.pop_grapheme(word), dict.get(grid, coord) {
    Ok(#(first, "")), Ok(v) if first == v -> 1
    Ok(#(first, rest)), Ok(v) if first == v ->
      scan_for_word(grid, rest, coord.go(coord, dir), dir)
    _, _ -> 0
  }
}

pub fn pt_1(input: Grid) {
  count_xmases(input, coord.origin, 0)
}

fn find_x_mas(grid: Grid, coord: Coord, acc: Int) -> Int {
  use <- bool.guard(coord.r == max, acc)
  use <- bool.lazy_guard(coord.c == max, fn() {
    find_x_mas(grid, coord.next_row(coord), acc)
  })

  case dict.get(grid, coord) {
    Ok("A") -> acc + live_mas(grid, coord)
    _ -> acc
  }
  |> find_x_mas(grid, coord.next_col(coord), _)
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

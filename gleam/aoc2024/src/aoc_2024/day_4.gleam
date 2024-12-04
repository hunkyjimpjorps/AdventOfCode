import gleam/bool
import gleam/dict.{type Dict}
import gleam/list
import gleam/result
import gleam/string

pub type Coord {
  Coord(r: Int, c: Int)
}

fn next_col(coord: Coord) {
  Coord(coord.r, coord.c + 1)
}

fn next_row(coord: Coord) {
  Coord(coord.r + 1, 0)
}

fn go(coord: Coord, direction: Coord) {
  Coord(coord.r + direction.r, coord.c + direction.c)
}

pub type Grid =
  Dict(Coord, String)

const directions = [
  Coord(-1, -1),
  Coord(-1, 0),
  Coord(-1, 1),
  Coord(0, -1),
  Coord(0, 1),
  Coord(1, -1),
  Coord(1, 0),
  Coord(1, 1),
]

const max = 140

pub fn parse(input: String) -> Grid {
  {
    use row, r <- list.index_map(string.split(input, "\n"))
    use col, c <- list.index_map(string.to_graphemes(row))
    #(Coord(r, c), col)
  }
  |> list.flatten
  |> dict.from_list
}

fn count_words(grid: Grid, word: String, coord: Coord, acc: Int) -> Int {
  use <- bool.guard(coord.r == max, acc)
  use <- bool.lazy_guard(coord.c == max, fn() {
    count_words(grid, word, next_row(coord), acc)
  })

  let found =
    directions
    |> list.filter_map(scan_for_word(grid, word, coord, _))
    |> list.length
  count_words(grid, word, next_col(coord), acc + found)
}

fn scan_for_word(grid: Grid, word: String, coord: Coord, dir: Coord) {
  case string.pop_grapheme(word), dict.get(grid, coord) {
    _, Error(_) -> Error(Nil)
    Ok(#(first, "")), Ok(v) if first == v -> Ok(Nil)
    Ok(#(first, rest)), Ok(v) if first == v ->
      scan_for_word(grid, rest, go(coord, dir), dir)
    _, _ -> Error(Nil)
  }
}

pub fn pt_1(input: Grid) {
  count_words(input, "XMAS", Coord(0, 0), 0)
}

fn find_x_mas(grid: Grid, coord: Coord, acc: Int) -> Int {
  use <- bool.guard(coord.r == max, acc)
  use <- bool.lazy_guard(coord.c == max, fn() {
    find_x_mas(grid, next_row(coord), acc)
  })

  case dict.get(grid, coord) {
    Ok("A") -> find_x_mas(grid, next_col(coord), acc + live_mas(grid, coord))
    _ -> find_x_mas(grid, next_col(coord), acc)
  }
}

fn live_mas(grid: Grid, coord: Coord) {
  let found =
    [Coord(-1, -1), Coord(1, 1), Coord(-1, 1), Coord(1, -1)]
    |> list.map(fn(dir) { dict.get(grid, go(coord, dir)) })
    |> result.values()
    |> string.join("")

  case found {
    "MSMS" | "MSSM" | "SMSM" | "SMMS" -> 1
    _ -> 0
  }
}

pub fn pt_2(input: Grid) {
  find_x_mas(input, Coord(0, 0), 0)
}

import gleam/bool
import gleam/dict.{type Dict}
import gleam/list
import gleam/result
import gleam/string

pub type Coord {
  Coord(r: Int, c: Int)
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

const max = 139

pub fn parse(input: String) -> Grid {
  {
    use row, r <- list.index_map(string.split(input, "\n"))
    use col, c <- list.index_map(string.to_graphemes(row))
    #(Coord(r, c), col)
  }
  |> list.flatten
  |> dict.from_list
}

fn find_word(
  grid: Grid,
  word: String,
  coord: Coord,
  acc: List(List(Coord)),
) -> List(List(Coord)) {
  use <- bool.guard(coord.r == max + 1, acc)
  use <- bool.lazy_guard(coord.c == max + 1, fn() {
    find_word(grid, word, Coord(coord.r + 1, 0), acc)
  })

  let found =
    directions
    |> list.map(scan_for_word(grid, word, coord, _, []))
    |> result.values
  find_word(grid, word, Coord(coord.r, coord.c + 1), list.append(found, acc))
}

fn scan_for_word(grid: Grid, word: String, c: Coord, d: Coord, acc) {
  case string.pop_grapheme(word) {
    Error(_) -> Error(Nil)
    Ok(#(first, "")) ->
      case dict.get(grid, c) == Ok(first) {
        True -> Ok([c, ..acc])
        False -> Error(Nil)
      }
    Ok(#(first, rest)) ->
      case dict.get(grid, c) == Ok(first) {
        True ->
          scan_for_word(grid, rest, Coord(c.r + d.r, c.c + d.c), d, [c, ..acc])
        False -> Error(Nil)
      }
  }
}

pub fn pt_1(input: Grid) {
  find_word(input, "XMAS", Coord(0, 0), [])
  |> list.length()
}

fn find_x_mas(grid: Grid, coord: Coord, acc: List(Coord)) -> List(Coord) {
  use <- bool.guard(coord.r == max + 1, acc)
  use <- bool.lazy_guard(coord.c == max + 1, fn() {
    find_x_mas(grid, Coord(coord.r + 1, 0), acc)
  })

  case dict.get(grid, coord) {
    Ok("A") -> {
      let new_acc = case live_mas(grid, coord) {
        True -> [coord, ..acc]
        False -> acc
      }
      find_x_mas(grid, Coord(coord.r, coord.c + 1), new_acc)
    }
    _ -> find_x_mas(grid, Coord(coord.r, coord.c + 1), acc)
  }
}

fn live_mas(grid: Grid, coord: Coord) {
  let found =
    [Coord(-1, -1), Coord(1, 1), Coord(-1, 1), Coord(1, -1)]
    |> list.map(fn(dir) {
      dict.get(grid, Coord(coord.r + dir.r, coord.c + dir.c))
    })
    |> result.values()
    |> string.join("")

  case found {
    "MSMS" | "MSSM" | "SMSM" | "SMMS" -> True
    _ -> False
  }
}

pub fn pt_2(input: Grid) {
  find_x_mas(input, Coord(0, 0), []) |> list.length()
}

import adglent.{First, Second}
import gleam/bool
import gleam/dict.{type Dict}
import gleam/list
import gleam/int
import gleam/io
import gleam/set.{type Set}
import gleam/string

type Posn {
  Posn(row: Int, col: Int)
}

fn add_posns(p1: Posn, p2: Posn) -> Posn {
  Posn(p1.row + p2.row, p1.col + p2.col)
}

type PipeGrid =
  Dict(Posn, String)

const north = Posn(-1, 0)

const south = Posn(1, 0)

const east = Posn(0, 1)

const west = Posn(0, -1)

const initial_directions = [
  #(north, ["|", "7", "F"]),
  #(south, ["|", "J", "L"]),
  #(east, ["-", "J", "7"]),
  #(west, ["-", "F", "L"]),
]

fn pipe_neighbors(pipe: String) -> List(Posn) {
  case pipe {
    "|" -> [north, south]
    "-" -> [east, west]
    "L" -> [north, east]
    "F" -> [south, east]
    "7" -> [south, west]
    "J" -> [north, west]
    _ -> panic as "bad pipe"
  }
}

fn make_grid(input: String) -> PipeGrid {
  {
    use r, row <- list.index_map(string.split(input, "\n"))
    use c, col <- list.index_map(string.to_graphemes(row))
    #(Posn(r, c), col)
  }
  |> list.flatten
  |> dict.from_list
}

fn valid_start_direction(grid: PipeGrid, s: Posn) {
  let assert [dir, ..] = {
    use d <- list.filter_map(initial_directions)
    let #(delta, valids) = d
    let neighbor = add_posns(s, delta)
    case dict.get(grid, neighbor) {
      Ok(pipe) ->
        case list.contains(valids, pipe) {
          True -> Ok(neighbor)
          False -> Error(Nil)
        }
      Error(_) -> Error(Nil)
    }
  }
  dir
}

fn to_next_pipe(current: Posn, grid: PipeGrid, acc: List(Posn)) {
  let assert [prev, ..] = acc
  let assert Ok(pipe) = dict.get(grid, current)
  use <- bool.guard(pipe == "S", [current, ..acc])
  let assert [next] = {
    pipe
    |> pipe_neighbors
    |> list.filter_map(fn(p) {
      case add_posns(p, current) {
        neighbor if neighbor == prev -> Error(Nil)
        neighbor -> Ok(neighbor)
      }
    })
  }
  to_next_pipe(next, grid, [current, ..acc])
}

pub fn part1(input: String) {
  let grid =
    input
    |> make_grid

  let assert Ok(s) =
    grid
    |> dict.filter(fn(_, v) { v == "S" })
    |> dict.keys
    |> list.first

  grid
  |> valid_start_direction(s)
  |> to_next_pipe(grid, [s])
  |> list.length
  |> fn(i) { { { i - 1 } / 2 } }
  |> string.inspect
}

fn trace_ray(p: Posn, loop: Set(Posn), grid: PipeGrid) -> Bool {
  use <- bool.guard(set.contains(loop, p), False)
  int.is_odd(count_crossings(p, loop, grid, 0, ""))
}

fn count_crossings(
  p: Posn,
  loop: Set(Posn),
  grid: PipeGrid,
  acc: Int,
  corner: String,
) {
  let maybe_cell = dict.get(grid, p)
  use <- bool.guard(maybe_cell == Error(Nil), acc)
  let assert Ok(cell) = maybe_cell
  let next = add_posns(p, east)
  case set.contains(loop, p) {
    False -> count_crossings(next, loop, grid, acc, corner)
    True ->
      case corner, cell {
        _, "|" -> count_crossings(next, loop, grid, acc + 1, corner)
        _, "F" | _, "L" -> count_crossings(next, loop, grid, acc, cell)
        "F", "J" | "L", "7" -> count_crossings(next, loop, grid, acc + 1, "")
        "F", "7" | "L", "J" -> count_crossings(next, loop, grid, acc, "")
        _, _ -> count_crossings(next, loop, grid, acc, corner)
      }
  }
}

pub fn part2(input: String) {
  let grid =
    input
    |> make_grid

  let assert Ok(s) =
    grid
    |> dict.filter(fn(_, v) { v == "S" })
    |> dict.keys
    |> list.first

  let loop_pipes =
    grid
    |> valid_start_direction(s)
    |> to_next_pipe(grid, [s])
    |> set.from_list

  grid
  |> dict.keys
  |> list.filter(trace_ray(_, loop_pipes, grid))
  |> list.length()
  |> string.inspect
}

pub fn main() {
  let assert Ok(part) = adglent.get_part()
  let assert Ok(input) = adglent.get_input("10")
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

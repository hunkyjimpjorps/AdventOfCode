import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/set.{type Set}
import gleam/string
import my_utils/coord.{type Coord, Coord}

fn add_coords(p1: Coord, p2: Coord) -> Coord {
  Coord(p1.r + p2.r, p1.c + p2.c)
}

type PipeGrid =
  Dict(Coord, String)

const north = Coord(-1, 0)

const south = Coord(1, 0)

const east = Coord(0, 1)

const west = Coord(0, -1)

const initial_directions = [
  #(north, ["|", "7", "F"]), #(south, ["|", "J", "L"]), #(east, ["-", "J", "7"]),
  #(west, ["-", "F", "L"]),
]

fn pipe_neighbors(pipe: String) -> List(Coord) {
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
    use row, r <- list.index_map(string.split(input, "\n"))
    use col, c <- list.index_map(string.to_graphemes(row))
    #(Coord(r, c), col)
  }
  |> list.flatten
  |> dict.from_list
}

fn valid_start_direction(grid: PipeGrid, s: Coord) {
  let assert [dir, ..] = {
    use d <- list.filter_map(initial_directions)
    let #(delta, valids) = d
    let neighbor = add_coords(s, delta)
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

fn to_next_pipe(current: Coord, grid: PipeGrid, acc: List(Coord)) {
  let assert [prev, ..] = acc
  let assert Ok(pipe) = dict.get(grid, current)
  use <- bool.guard(pipe == "S", [current, ..acc])
  let assert [next] = {
    pipe
    |> pipe_neighbors
    |> list.filter_map(fn(p) {
      case add_coords(p, current) {
        neighbor if neighbor == prev -> Error(Nil)
        neighbor -> Ok(neighbor)
      }
    })
  }
  to_next_pipe(next, grid, [current, ..acc])
}

fn trace_ray(p: Coord, loop: Set(Coord), grid: PipeGrid) -> Bool {
  use <- bool.guard(set.contains(loop, p), False)
  int.is_odd(count_crossings(p, loop, grid, 0, ""))
}

fn count_crossings(
  p: Coord,
  loop: Set(Coord),
  grid: PipeGrid,
  acc: Int,
  corner: String,
) {
  let maybe_cell = dict.get(grid, p)
  use <- bool.guard(maybe_cell == Error(Nil), acc)
  let assert Ok(cell) = maybe_cell
  let next = add_coords(p, east)
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

pub fn pt_1(input: String) {
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
  |> fn(i) { { i - 1 } / 2 }
}

pub fn pt_2(input: String) {
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
}

import gleam/bool
import gleam/set
import gleam/string
import my_utils/to
import my_utils/xy.{type XY, XY}

type Direction {
  North
  East
  South
  West
}

fn to_unit(facing: Direction) {
  case facing {
    North -> XY(0, 1)
    East -> XY(1, 0)
    South -> XY(0, -1)
    West -> XY(-1, 0)
  }
}

fn turn_right(facing: Direction) {
  case facing {
    North -> East
    East -> South
    South -> West
    West -> North
  }
}

fn turn_left(facing: Direction) {
  case facing {
    North -> West
    West -> South
    South -> East
    East -> North
  }
}

fn walk(current: XY, facing: Direction, steps: Int) {
  let unit = to_unit(facing)
  XY(current.x + unit.x * steps, current.y + unit.y * steps)
}

fn go(current, facing, directions) {
  case directions {
    ["R" <> n, ..rest] ->
      go(walk(current, turn_right(facing), to.int(n)), turn_right(facing), rest)
    ["L" <> n, ..rest] ->
      go(walk(current, turn_left(facing), to.int(n)), turn_left(facing), rest)
    [] -> current
    _ -> panic
  }
}

pub fn parse(input: String) {
  input |> string.split(", ")
}

pub fn pt_1(input: List(String)) {
  XY(0, 0) |> go(North, input) |> xy.manhattan_dist(XY(0, 0))
}

fn visit(current, facing, steps, seen, directions) {
  use <- bool.guard(set.contains(seen, current), current)
  case steps, directions {
    0, ["R" <> n, ..rest] ->
      visit(current, turn_right(facing), to.int(n), seen, rest)
    0, ["L" <> n, ..rest] ->
      visit(current, turn_left(facing), to.int(n), seen, rest)
    0, [] -> current
    n, _ -> {
      let next = walk(current, facing, 1)
      visit(next, facing, n - 1, set.insert(seen, current), directions)
    }
  }
}

pub fn pt_2(input: List(String)) {
  XY(0, 0) |> visit(North, 0, set.new(), input) |> xy.manhattan_dist(XY(0, 0))
}

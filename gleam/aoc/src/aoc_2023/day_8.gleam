import gleam/bool
import gleam/dict.{type Dict}
import gleam/list
import gleam/option.{Some}
import gleam/regexp.{Match}
import gleam/string
import gleam/yielder.{type Yielder, Next}
import gleam_community/maths

pub type Paths {
  Paths(to_left: String, to_right: String)
}

type Maze =
  Dict(String, Paths)

pub type Input {
  Input(directions: Yielder(String), maze: Dict(String, Paths))
}

pub fn parse(input: String) -> Input {
  let assert [directions_str, maze_str] = string.split(input, "\n\n")

  let directions =
    directions_str
    |> string.to_graphemes()
    |> yielder.from_list
    |> yielder.cycle

  let assert Ok(re) = regexp.from_string("(...) = \\((...), (...)\\)")
  let maze =
    maze_str
    |> string.split("\n")
    |> list.map(fn(str) {
      let assert [Match(submatches: [Some(name), Some(left), Some(right)], ..)] =
        regexp.scan(re, str)
      #(name, Paths(left, right))
    })
    |> dict.from_list

  Input(directions, maze)
}

fn to_next_step(
  current: String,
  stop_at: String,
  count: Int,
  directions: Yielder(String),
  maze: Maze,
) -> Int {
  use <- bool.guard(string.ends_with(current, stop_at), count)
  let assert Next(next_direction, rest_directions) = yielder.step(directions)
  let assert Ok(paths) = dict.get(maze, current)
  case next_direction {
    "L" -> paths.to_left
    "R" -> paths.to_right
    _ -> panic as "bad direction"
  }
  |> to_next_step(stop_at, count + 1, rest_directions, maze)
}

pub fn pt_1(input: Input) {
  to_next_step("AAA", "ZZZ", 0, input.directions, input.maze)
}

pub fn pt_2(input: Input) {
  use acc, name <- list.fold(dict.keys(input.maze), 1)
  case string.ends_with(name, "A") {
    False -> acc
    True ->
      to_next_step(name, "Z", 0, input.directions, input.maze)
      |> maths.lcm(acc)
  }
}

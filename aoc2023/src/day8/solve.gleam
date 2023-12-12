import adglent.{First, Second}
import gleam/bool
import gleam/dict.{type Dict}
import gleam/io
import gleam/iterator.{type Iterator, Next}
import gleam/list
import gleam/option.{Some}
import gleam/string
import gleam/regex.{type Match, Match}
import gleam_community/maths/arithmetics

type Paths {
  Paths(to_left: String, to_right: String)
}

type Maze =
  Dict(String, Paths)

fn parse(input: String) -> #(Iterator(String), Dict(String, Paths)) {
  let assert [directions_str, maze_str] = string.split(input, "\n\n")

  let directions =
    directions_str
    |> string.to_graphemes()
    |> iterator.from_list
    |> iterator.cycle

  let assert Ok(re) = regex.from_string("(...) = \\((...), (...)\\)")
  let maze =
    maze_str
    |> string.split("\n")
    |> list.map(fn(str) {
      let assert [Match(submatches: [Some(name), Some(left), Some(right)], ..)] =
        regex.scan(re, str)
      #(name, Paths(left, right))
    })
    |> dict.from_list

  #(directions, maze)
}

fn to_next_step(
  current: String,
  stop_at: String,
  count: Int,
  directions: Iterator(String),
  maze: Maze,
) -> Int {
  use <- bool.guard(string.ends_with(current, stop_at), count)
  let assert Next(next_direction, rest_directions) = iterator.step(directions)
  let assert Ok(paths) = dict.get(maze, current)
  case next_direction {
    "L" -> paths.to_left
    "R" -> paths.to_right
    _ -> panic as "bad direction"
  }
  |> to_next_step(stop_at, count + 1, rest_directions, maze)
}

pub fn part1(input: String) -> Int {
  let #(directions, maze) = parse(input)

  to_next_step("AAA", "ZZZ", 0, directions, maze)
}

pub fn part2(input: String) -> Int {
  let #(directions, maze) = parse(input)

  use acc, name <- list.fold(dict.keys(maze), 1)
  case string.ends_with(name, "A") {
    False -> acc
    True ->
      to_next_step(name, "Z", 0, directions, maze)
      |> arithmetics.lcm(acc)
  }
}

pub fn main() {
  let assert Ok(part) = adglent.get_part()
  let assert Ok(input) = adglent.get_input("8")
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

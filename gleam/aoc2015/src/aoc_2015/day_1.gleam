import gleam/bool
import gleam/list
import gleam/string

type Direction {
  Up
  Down
}

fn parse(input: String) {
  use ch <- list.map(string.to_graphemes(input))
  case ch {
    "(" -> Up
    ")" -> Down
    _ -> panic
  }
}

fn traverse(directions: List(Direction), starting_at current_floor: Int) -> Int {
  case directions {
    [] -> current_floor
    [Up, ..rest] -> traverse(rest, current_floor + 1)
    [Down, ..rest] -> traverse(rest, current_floor - 1)
  }
}

pub fn pt_1(input: String) {
  input |> parse |> traverse(starting_at: 0)
}

fn find_basement(
  directions: List(Direction),
  starting_at current_floor: Int,
  initial_count count: Int,
) -> Int {
  use <- bool.guard(current_floor == -1, count)
  case directions {
    [] -> panic
    [Up, ..rest] -> find_basement(rest, current_floor + 1, count + 1)
    [Down, ..rest] -> find_basement(rest, current_floor - 1, count + 1)
  }
}

pub fn pt_2(input: String) {
  input |> parse |> find_basement(starting_at: 0, initial_count: 0)
}

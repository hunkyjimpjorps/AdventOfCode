import gleam/dict
import gleam/int
import gleam/list

type Direction {
  Up
  Down
  Left
  Right
}

type State {
  State(
    x: Int,
    y: Int,
    direction: Direction,
    branch_length: Int,
    remaining: Int,
  )
}

fn starting_state() -> State {
  State(0, 0, Right, 1, 1)
}

fn update_state(state: State) -> State {
  case state {
    State(x, y, Right, len, 0) -> State(x, y + 1, Up, len, len - 1)
    State(x, y, Up, len, 0) -> State(x - 1, y, Left, len + 1, len)
    State(x, y, Left, len, 0) -> State(x, y - 1, Down, len, len - 1)
    State(x, y, Down, len, 0) -> State(x + 1, y, Right, len + 1, len)
    State(x, y, Right, len, rem) -> State(x + 1, y, Right, len, rem - 1)
    State(x, y, Up, len, rem) -> State(x, y + 1, Up, len, rem - 1)
    State(x, y, Left, len, rem) -> State(x - 1, y, Left, len, rem - 1)
    State(x, y, Down, len, rem) -> State(x, y - 1, Down, len, rem - 1)
  }
}

type Grid =
  dict.Dict(#(Int, Int), Int)

pub fn parse(input: String) -> Int {
  let assert Ok(n) = int.parse(input)
  n
}

pub fn pt_1(input: Int) -> Int {
  next_step(1, input, starting_state())
}

fn next_step(current: Int, target: Int, state: State) -> Int {
  case current == target {
    True -> int.absolute_value(state.x) + int.absolute_value(state.y)
    False -> next_step(current + 1, target, update_state(state))
  }
}

pub fn pt_2(input: Int) -> Int {
  let grid: Grid = dict.from_list([#(#(0, 0), 1)])

  add_next_cell(input, starting_state(), grid)
}

fn neighbors(coord: #(Int, Int)) -> List(#(Int, Int)) {
  let #(x, y) = coord

  use dx <- list.flat_map(list.range(-1, 1))
  use dy <- list.map(list.range(-1, 1))
  #(x + dx, y + dy)
}

fn add_next_cell(target: Int, state: State, grid: Grid) -> Int {
  let next_cell = update_state(state)
  let coords = #(next_cell.x, next_cell.y)
  let value =
    list.fold(neighbors(coords), 0, fn(acc, coord) {
      case dict.get(grid, coord) {
        Ok(n) -> acc + n
        _err -> acc
      }
    })

  case value >= target {
    True -> value
    False -> add_next_cell(target, next_cell, dict.insert(grid, coords, value))
  }
}

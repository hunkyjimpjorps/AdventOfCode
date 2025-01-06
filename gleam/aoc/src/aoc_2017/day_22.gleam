import gleam/dict.{type Dict}
import gleam/list
import gleam/result
import gleam/string
import gleam/yielder
import my_utils/from
import my_utils/xy.{type Direction, type XY, Up, XY}

pub type Node {
  Clean
  Weakened
  Infected
  Flagged
}

pub type State {
  State(
    network: Dict(XY, Node),
    infections: Int,
    current: XY,
    facing: Direction,
  )
}

pub fn parse(input: String) {
  let network =
    from.grid(input, fn(r, c) { XY(c, r) }, fn(c) {
      case c {
        "." -> Clean
        "#" -> Infected
        _ -> panic
      }
    })

  let mid = input |> string.split("\n") |> list.length |> fn(n) { n / 2 }

  State(network, 0, XY(mid, mid), Up)
}

fn update_state(state: State, node, facing) {
  State(
    network: dict.insert(state.network, state.current, node),
    infections: case node {
      Infected -> state.infections + 1
      _ -> state.infections
    },
    current: xy.step(state.current, facing),
    facing:,
  )
}

fn next_burst(state) {
  let State(network:, current:, facing:, ..) = state
  case dict.get(network, current) {
    Ok(Clean) | Error(Nil) ->
      update_state(state, Infected, xy.turn_left(facing))
    Ok(Infected) -> update_state(state, Clean, xy.turn_right(facing))
    _ -> panic
  }
}

pub fn pt_1(input: State) {
  yielder.iterate(input, next_burst)
  |> yielder.at(10_000)
  |> result.map(fn(c) { c.infections })
}

fn next_evolved_burst(state) {
  let State(network:, current:, facing:, ..) = state
  case dict.get(network, current) {
    Ok(Clean) | Error(Nil) ->
      update_state(state, Weakened, xy.turn_left(facing))
    Ok(Weakened) -> update_state(state, Infected, facing)
    Ok(Infected) -> update_state(state, Flagged, xy.turn_right(facing))
    Ok(Flagged) -> update_state(state, Clean, xy.reverse(facing))
  }
}

pub fn pt_2(input: State) {
  yielder.iterate(input, next_evolved_burst)
  |> yielder.at(10_000_000)
  |> result.map(fn(c) { c.infections })
}

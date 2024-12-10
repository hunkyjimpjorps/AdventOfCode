import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/set
import my_utils/coord.{type Coord, Coord}
import my_utils/from
import my_utils/to

pub fn parse(input: String) -> Dict(Coord, Int) {
  from.grid(input, to.int)
}

fn look_for_summit(current: Coord, grid: Dict(Coord, Int), summits: List(Coord)) {
  let assert Ok(elevation) = dict.get(grid, current)
  case elevation {
    9 -> [current, ..summits]
    elev -> {
      current
      |> coord.neighbors(coord.cardinal_directions)
      |> list.fold(summits, fn(acc, n) {
        case dict.get(grid, n) == Ok(elev + 1) {
          True -> look_for_summit(n, grid, acc)
          False -> acc
        }
      })
    }
  }
}

fn rate_trails(input: Dict(Coord, Int), using: fn(List(Coord)) -> Int) {
  let trailheads = input |> dict.filter(fn(_, v) { v == 0 }) |> dict.keys
  use acc, trailhead <- list.fold(trailheads, 0)
  input
  |> look_for_summit(trailhead, _, [])
  |> using
  |> int.add(acc)
}

pub fn pt_1(input: Dict(Coord, Int)) {
  rate_trails(input, fn(trail) { trail |> set.from_list |> set.size })
}

pub fn pt_2(input: Dict(Coord, Int)) {
  rate_trails(input, list.length)
}

import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/result
import gleam/set.{type Set}
import my_utils/from
import my_utils/xy.{type XY, XY}
import parallel_map

pub type Tile {
  Start
  End
  Wall
  Path
}

pub fn parse(input: String) -> Dict(XY, Tile) {
  from.grid(input, xy.from_input, fn(c) {
    case c {
      "S" -> Start
      "E" -> End
      "#" -> Wall
      "." -> Path
      _ -> panic
    }
  })
}

fn enumerate_path(input: Dict(XY, Tile)) -> Dict(XY, Int) {
  let assert [start] =
    input |> dict.filter(fn(_, v) { v == Start }) |> dict.keys
  let path = dict.new() |> dict.insert(start, 0)
  do_enumerate(start, path, input, 0, set.new() |> set.insert(start))
}

fn do_enumerate(
  position: XY,
  acc: Dict(XY, Int),
  grid: Dict(XY, Tile),
  i: Int,
  seen: Set(XY),
) -> Dict(XY, Int) {
  let assert Ok(next) =
    position
    |> xy.neighbors(xy.cardinal_directions)
    |> list.find(fn(n) {
      !set.contains(seen, n) && dict.get(grid, n) != Ok(Wall)
    })
  let acc = dict.insert(acc, next, i)
  case dict.get(grid, next) {
    Ok(End) -> acc
    Ok(Path) -> do_enumerate(next, acc, grid, i + 1, set.insert(seen, next))
    _ -> panic
  }
}

fn reachable_nodes(p: XY, distance: Int) -> List(XY) {
  use dy <- list.flat_map(list.range(-distance, distance))
  let span_size = distance - int.absolute_value(dy)
  use dx <- list.map(list.range(-span_size, span_size))
  XY(dx + p.x, dy + p.y)
}

fn search_for_shortcuts(numbered_path: Dict(XY, Int), reach: Int) -> Int {
  parallel_map.list_pmap(
    dict.keys(numbered_path),
    fn(a) {
      use acc, b <- list.fold(reachable_nodes(a, reach), 0)
      let dist = xy.manhattan_dist(a, b)
      case dict.get(numbered_path, a), dict.get(numbered_path, b) {
        Ok(n), Ok(m) if m - n - dist >= 100 -> acc + 1
        _, _ -> acc
      }
    },
    parallel_map.MatchSchedulersOnline,
    1000,
  )
  |> result.values
  |> int.sum
}

pub fn pt_1(input: Dict(XY, Tile)) -> Int {
  input
  |> enumerate_path()
  |> search_for_shortcuts(2)
}

pub fn pt_2(input: Dict(XY, Tile)) -> Int {
  input
  |> enumerate_path()
  |> search_for_shortcuts(20)
}

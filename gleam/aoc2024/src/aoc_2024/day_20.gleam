import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/set
import my_utils/coord.{type Coord, Coord}
import my_utils/from

pub type Tile {
  Start
  End
  Wall
  Path
}

pub fn parse(input: String) -> Dict(Coord, Tile) {
  from.grid(input, fn(c) {
    case c {
      "S" -> Start
      "E" -> End
      "#" -> Wall
      "." -> Path
      _ -> panic
    }
  })
}

fn enumerate_path(position, acc, grid, index, seen) {
  let assert [next] =
    position
    |> coord.neighbors(coord.cardinal_directions)
    |> list.filter(fn(n) {
      !set.contains(seen, n) && dict.get(grid, n) != Ok(Wall)
    })

  case dict.get(grid, next) {
    Ok(End) -> dict.insert(acc, next, index)
    Ok(Path) ->
      dict.insert(acc, next, index)
      |> enumerate_path(next, _, grid, index + 1, set.insert(seen, next))
    _ -> panic
  }
}

fn reachable_nodes(p: Coord, distance: Int) -> List(Coord) {
  let Coord(r, c) = p
  list.range(-distance, distance)
  |> list.flat_map(fn(y) {
    let span_size = distance - int.absolute_value(y)
    list.range(-span_size, span_size) |> list.map(fn(x) { Coord(x + r, y + c) })
  })
}

fn search_for_shortcuts(numbered_path, reach) {
  {
    use outer_acc, a <- list.fold(dict.keys(numbered_path), 0)
    use inner_acc, b <- list.fold(reachable_nodes(a, reach), outer_acc)
    let dist = coord.manhattan_dist(a, b)
    case dict.get(numbered_path, a), dict.get(numbered_path, b) {
      Ok(n), Ok(m) if m - n - dist >= 100 -> inner_acc + 1
      _, _ -> inner_acc
    }
  }
}

pub fn pt_1(input: Dict(Coord, Tile)) {
  let assert [start] =
    input |> dict.filter(fn(_, v) { v == Start }) |> dict.keys
  let path = dict.new() |> dict.insert(start, 0)

  enumerate_path(start, path, input, 0, set.new() |> set.insert(start))
  |> search_for_shortcuts(2)
}

pub fn pt_2(input: Dict(Coord, Tile)) {
  let assert [start] =
    input |> dict.filter(fn(_, v) { v == Start }) |> dict.keys
  let path = dict.new() |> dict.insert(start, 0)

  enumerate_path(start, path, input, 0, set.new() |> set.insert(start))
  |> search_for_shortcuts(20)
}

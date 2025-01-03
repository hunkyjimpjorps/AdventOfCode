import gleam/bool
import gleam/dict.{type Dict}
import gleam/list
import gleam/result
import gleam/set.{type Set}
import my_utils/coord.{type Coord, Coord}
import my_utils/from

type Direction {
  Up
  Right
  Down
  Left
}

type Light {
  Light(coord: Coord, dir: Direction)
}

fn move(l: Light) -> Light {
  let Light(p, dir) = l
  case dir {
    Up -> Light(..l, coord: Coord(..p, r: p.r - 1))
    Down -> Light(..l, coord: Coord(..p, r: p.r + 1))
    Left -> Light(..l, coord: Coord(..p, c: p.c - 1))
    Right -> Light(..l, coord: Coord(..p, c: p.c + 1))
  }
}

fn transform(l: Light, cell: Result(String, Nil)) -> List(Light) {
  use <- bool.guard(result.is_error(cell), [])
  let assert Ok(c) = cell
  let Light(p, dir) = l
  case dir, c {
    // no change
    _, "." | Up, "|" | Down, "|" | Left, "-" | Right, "-" -> [l]
    // diagonal mirrors
    Left, "/" -> [Light(p, Down)]
    Down, "/" -> [Light(p, Left)]
    Right, "/" -> [Light(p, Up)]
    Up, "/" -> [Light(p, Right)]
    Left, "\\" -> [Light(p, Up)]
    Up, "\\" -> [Light(p, Left)]
    Right, "\\" -> [Light(p, Down)]
    Down, "\\" -> [Light(p, Right)]
    // splitters
    Left, "|" | Right, "|" -> [Light(p, Up), Light(p, Down)]
    Up, "-" | Down, "-" -> [Light(p, Left), Light(p, Right)]
    _, _ -> panic as "unrecognized cell type"
  }
}

fn energize(lights: List(Light), visited: Set(Light), grid: Dict(Coord, String)) {
  let next_positions =
    lights
    |> list.flat_map(fn(l) {
      let next = move(l)
      transform(next, dict.get(grid, next.coord))
    })
    |> list.filter(fn(l) { !set.contains(visited, l) })
  let all_visited = set.union(set.from_list(next_positions), visited)
  case visited == all_visited {
    True ->
      set.fold(visited, set.new(), fn(acc, l) { set.insert(acc, l.coord) })
      |> set.to_list
      |> list.length
    False -> energize(next_positions, all_visited, grid)
  }
}

pub fn pt_1(input: String) {
  let grid = from.grid(input, Coord, fn(c) { c })

  [Light(Coord(0, -1), Right)]
  |> energize(set.new(), grid)
}

pub fn pt_2(input: String) {
  let grid = from.grid(input, Coord, fn(c) { c })

  let Coord(rows, cols) =
    list.fold(dict.keys(grid), Coord(0, 0), fn(acc, p) {
      case acc.r + acc.c > p.r + p.c {
        True -> acc
        False -> p
      }
    })

  let all_starts =
    list.flatten([
      list.map(list.range(0, rows), fn(r) { Light(Coord(r, -1), Right) }),
      list.map(list.range(0, rows), fn(r) { Light(Coord(r, cols + 1), Left) }),
      list.map(list.range(0, cols), fn(c) { Light(Coord(-1, c), Down) }),
      list.map(list.range(0, cols), fn(c) { Light(Coord(rows + 1, c), Up) }),
    ])

  use acc, p <- list.fold(all_starts, 0)
  let energized = energize([p], set.new(), grid)
  case acc > energized {
    True -> acc
    False -> energized
  }
}

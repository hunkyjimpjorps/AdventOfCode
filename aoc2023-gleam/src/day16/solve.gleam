import adglent.{First, Second}
import gleam/bool
import gleam/dict.{type Dict}
import gleam/io
import gleam/list
import gleam/result
import gleam/set.{type Set}
import utilities/array2d.{type Posn, Posn}

type Direction {
  Up
  Right
  Down
  Left
}

type Light {
  Light(posn: Posn, dir: Direction)
}

fn move(l: Light) -> Light {
  let Light(p, dir) = l
  case dir {
    Up -> Light(..l, posn: Posn(..p, r: p.r - 1))
    Down -> Light(..l, posn: Posn(..p, r: p.r + 1))
    Left -> Light(..l, posn: Posn(..p, c: p.c - 1))
    Right -> Light(..l, posn: Posn(..p, c: p.c + 1))
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

fn energize(lights: List(Light), visited: Set(Light), grid: Dict(Posn, String)) {
  let next_positions =
    lights
    |> list.flat_map(fn(l) {
      let next = move(l)
      transform(next, dict.get(grid, next.posn))
    })
    |> list.filter(fn(l) { !set.contains(visited, l) })
  let all_visited = set.union(set.from_list(next_positions), visited)
  case visited == all_visited {
    True ->
      set.fold(visited, set.new(), fn(acc, l) { set.insert(acc, l.posn) })
      |> set.to_list
      |> list.length
    False -> energize(next_positions, all_visited, grid)
  }
}

pub fn part1(input: String) {
  let grid = array2d.parse_grid(input)

  [Light(Posn(0, -1), Right)]
  |> energize(set.new(), grid)
}

pub fn part2(input: String) {
  let grid = array2d.parse_grid(input)

  let Posn(rows, cols) = {
    use acc, p <- list.fold(dict.keys(grid), Posn(0, 0))
    case acc.r + acc.c > p.r + p.c {
      True -> acc
      False -> p
    }
  }

  let all_starts =
    list.concat([
      list.map(list.range(0, rows), fn(r) { Light(Posn(r, -1), Right) }),
      list.map(list.range(0, rows), fn(r) { Light(Posn(r, cols + 1), Left) }),
      list.map(list.range(0, cols), fn(c) { Light(Posn(-1, c), Down) }),
      list.map(list.range(0, cols), fn(c) { Light(Posn(rows + 1, c), Up) }),
    ])

  use acc, p <- list.fold(all_starts, 0)
  let energized = energize([p], set.new(), grid)
  case acc > energized {
    True -> acc
    False -> energized
  }
}

pub fn main() {
  let assert Ok(part) = adglent.get_part()
  let assert Ok(input) = adglent.get_input("16")
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

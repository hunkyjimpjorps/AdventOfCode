import gleam/bool
import gleam/dict.{type Dict}
import gleam/list
import gleam/set.{type Set}
import my_utils/coord.{type Coord, Coord}
import my_utils/from
import parallel_map

pub type Tile {
  Floor
  Obstruction
  Start
  Visited
}

pub type Direction {
  Up
  Right
  Down
  Left
}

pub fn parse(input: String) -> Dict(Coord, Tile) {
  from.grid(input, fn(c) {
    case c {
      "." -> Floor
      "#" -> Obstruction
      "^" -> Start
      _ -> panic
    }
  })
}

fn get_start(map: Dict(Coord, Tile)) -> Coord {
  let assert [start] = map |> dict.filter(fn(_, v) { v == Start }) |> dict.keys
  start
}

fn rotate(dir: Direction) -> Direction {
  case dir {
    Up -> Right
    Right -> Down
    Down -> Left
    Left -> Up
  }
}

fn towards(dir: Direction) -> Coord {
  case dir {
    Up -> Coord(-1, 0)
    Right -> Coord(0, 1)
    Down -> Coord(1, 0)
    Left -> Coord(0, -1)
  }
}

fn next_step(tile: Coord, dir: Direction, map: Dict(Coord, Tile)) {
  let ahead = coord.go(tile, towards(dir))
  case dict.get(map, ahead) {
    Ok(Floor) | Ok(Start) | Ok(Visited) ->
      next_step(ahead, dir, dict.insert(map, tile, Visited))
    Ok(Obstruction) -> next_step(tile, rotate(dir), map)
    Error(_) -> dict.insert(map, tile, Visited)
  }
}

pub fn pt_1(input: Dict(Coord, Tile)) -> Int {
  next_step(get_start(input), Up, input)
  |> dict.filter(fn(_, v) { v == Visited })
  |> dict.size
}

fn causes_loop(
  tile: Coord,
  dir: Direction,
  map: Dict(Coord, Tile),
  seen: Set(#(Coord, Direction)),
) -> Bool {
  use <- bool.guard(set.contains(seen, #(tile, dir)), True)
  let ahead = coord.go(tile, towards(dir))
  case dict.get(map, ahead) {
    Ok(Floor) | Ok(Start) | Ok(Visited) ->
      causes_loop(ahead, dir, map, set.insert(seen, #(tile, dir)))
    Ok(Obstruction) -> causes_loop(tile, rotate(dir), map, seen)
    Error(_) -> False
  }
}

pub fn pt_2(input: Dict(Coord, Tile)) {
  let candidates =
    next_step(get_start(input), Up, input)
    |> dict.filter(fn(_, v) { v == Visited })
    |> dict.keys
  let start = get_start(input)

  parallel_map.list_pmap(
    candidates,
    fn(candidate) {
      let tampered_map = dict.insert(input, candidate, Obstruction)
      causes_loop(start, Up, tampered_map, set.new())
    },
    parallel_map.MatchSchedulersOnline,
    1000,
  )
  |> list.count(fn(result) { result == Ok(True) })
}

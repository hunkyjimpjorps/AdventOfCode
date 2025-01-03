import gleam/bool
import gleam/dict.{type Dict}
import gleam/list
import gleam/result
import gleam/string
import my_utils/coord.{type Coord, Coord}
import my_utils/from

pub type Tile {
  Nothing
  Box
  Wall
  LeftBox
  RightBox
  Robot
}

pub type Direction {
  Up
  Down
  Left
  Right
}

type Found {
  Found(pos: Coord, tile: Tile)
}

fn to_delta(dir: Direction) -> Coord {
  case dir {
    Up -> Coord(-1, 0)
    Down -> Coord(1, 0)
    Left -> Coord(0, -1)
    Right -> Coord(0, 1)
  }
}

fn parse_map(input: String) -> Dict(Coord, Tile) {
  from.grid(input, Coord, fn(c) {
    case c {
      "." -> Nothing
      "O" -> Box
      "#" -> Wall
      "[" -> LeftBox
      "]" -> RightBox
      "@" -> Robot
      _ -> panic
    }
  })
}

fn parse_steps(input: String) -> List(Direction) {
  case input {
    "" -> []
    "\n" <> rest -> parse_steps(rest)
    "^" <> rest -> [Up, ..parse_steps(rest)]
    "v" <> rest -> [Down, ..parse_steps(rest)]
    "<" <> rest -> [Left, ..parse_steps(rest)]
    ">" <> rest -> [Right, ..parse_steps(rest)]
    _ -> panic
  }
}

fn next_step(
  robot: Coord,
  map: Dict(Coord, Tile),
  steps: List(Direction),
) -> Dict(Coord, Tile) {
  use <- bool.guard(list.is_empty(steps), map)
  let assert [next, ..rest] = steps
  let delta = to_delta(next)
  let maybe = coord.go(robot, delta)
  let assert Ok(at_destination) = dict.get(map, maybe)
  case at_destination {
    Nothing -> move_boxes([Found(robot, Robot)], map, maybe, rest, delta)
    LeftBox | RightBox | Box -> {
      let boxes = case next, at_destination {
        Left, _ | Right, _ | _, Box ->
          check_horiz_box(robot, map, delta, [Found(robot, Robot)])
        Up, _ | Down, _ ->
          check_vert_box(robot, map, delta, Ok([Found(robot, Robot)]))
      }
      case boxes {
        Ok(found_boxes) -> move_boxes(found_boxes, map, maybe, rest, delta)
        Error(_) -> next_step(robot, map, rest)
      }
    }
    _wall -> next_step(robot, map, rest)
  }
}

fn check_horiz_box(
  coord: Coord,
  map: Dict(Coord, Tile),
  delta: Coord,
  acc: List(Found),
) -> Result(List(Found), Nil) {
  let beyond = coord.go(coord, delta)
  let assert Ok(tile) = dict.get(map, coord)
  case dict.get(map, beyond) {
    Ok(Nothing) -> Ok([Found(coord, tile), ..acc])
    Ok(LeftBox) | Ok(RightBox) | Ok(Box) ->
      check_horiz_box(beyond, map, delta, [Found(coord, tile), ..acc])
    _wall -> Error(Nil)
  }
}

fn check_vert_box(
  coord: Coord,
  map: Dict(Coord, Tile),
  delta: Coord,
  acc: Result(List(Found), Nil),
) -> Result(List(Found), Nil) {
  let beyond = coord.go(coord, delta)
  let assert Ok(at_beyond) = dict.get(map, beyond)
  case at_beyond {
    Nothing -> acc
    LeftBox | RightBox -> {
      let dir = case at_beyond {
        LeftBox -> Right
        RightBox -> Left
        _ -> panic
      }
      list.try_map([beyond, coord.go(beyond, to_delta(dir))], fn(b) {
        let assert Ok(t) = dict.get(map, b)
        acc
        |> result.map(list.prepend(_, Found(b, t)))
        |> check_vert_box(b, map, delta, _)
      })
      |> result.map(list.flatten)
    }
    _wall -> Error(Nil)
  }
}

fn move_boxes(
  bs: List(Found),
  map: Dict(Coord, Tile),
  dest: Coord,
  next: List(Direction),
  d: Coord,
) -> Dict(Coord, Tile) {
  bs
  |> list.fold(map, fn(m, b) { dict.insert(m, b.pos, Nothing) })
  |> list.fold(bs, _, fn(m, b) { dict.insert(m, coord.go(b.pos, d), b.tile) })
  |> next_step(dest, _, next)
}

fn preprocess(input: String) -> String {
  input
  |> string.replace("#", "##")
  |> string.replace("O", "[]")
  |> string.replace(".", "..")
  |> string.replace("@", "@.")
}

fn update_coordinate_sum(acc: Int, k: Coord, v: Tile) -> Int {
  case v {
    Box | LeftBox -> k.c + 100 * k.r + acc
    _ -> acc
  }
}

pub fn pt_1(input: String) -> Int {
  let assert [map, steps] = string.split(input, "\n\n")
  let map = parse_map(map)
  let steps = parse_steps(steps)

  let assert [robot] = map |> dict.filter(fn(_, v) { v == Robot }) |> dict.keys

  dict.fold(next_step(robot, map, steps), 0, update_coordinate_sum)
}

pub fn pt_2(input: String) -> Int {
  let assert [map, steps] = string.split(input, "\n\n")
  let map = map |> preprocess |> parse_map
  let steps = parse_steps(steps)
  let assert [robot] = map |> dict.filter(fn(_, v) { v == Robot }) |> dict.keys

  dict.fold(next_step(robot, map, steps), 0, update_coordinate_sum)
}

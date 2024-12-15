import gleam/bool
import gleam/dict.{type Dict}
import gleam/list
import gleam/result
import gleam/string
import my_utils/coord.{type Coord, Coord}
import my_utils/from

pub type Tile {
  Robot
  Nothing
  Box
  Wall
  LeftBox
  RightBox
}

pub type Direction {
  Up
  Down
  Left
  Right
}

fn to_delta(dir: Direction) -> Coord {
  case dir {
    Up -> Coord(-1, 0)
    Down -> Coord(1, 0)
    Left -> Coord(0, -1)
    Right -> Coord(0, 1)
  }
}

fn parse_map(input: String) {
  from.grid(input, fn(c) {
    case c {
      "@" -> Robot
      "." -> Nothing
      "O" -> Box
      "#" -> Wall
      "[" -> LeftBox
      "]" -> RightBox
      _ -> panic as { "unexpected object" <> c }
    }
  })
}

fn parse_steps(input: String) {
  case input {
    "" -> []
    "\n" <> rest -> parse_steps(rest)
    "^" <> rest -> [Up, ..parse_steps(rest)]
    "v" <> rest -> [Down, ..parse_steps(rest)]
    "<" <> rest -> [Left, ..parse_steps(rest)]
    ">" <> rest -> [Right, ..parse_steps(rest)]
    _ -> panic as "unexpected instruction"
  }
}

fn next_step_simple(
  robot: Coord,
  map: Dict(Coord, Tile),
  steps: List(Direction),
) -> Dict(Coord, Tile) {
  use <- bool.guard(list.is_empty(steps), map)
  let assert [next, ..rest] = steps
  let delta = to_delta(next)
  let maybe = coord.go(robot, delta)
  case dict.get(map, maybe) {
    Ok(Nothing) -> move_boxes_simple([], map, robot, maybe, rest)
    Ok(Box) ->
      case check_box(maybe, map, delta, []) {
        Ok(boxes) -> move_boxes_simple(boxes, map, robot, maybe, rest)
        Error(_) -> next_step_simple(robot, map, rest)
      }
    Ok(Wall) -> next_step_simple(robot, map, rest)
    _ -> panic as "robot tried to do something invalid"
  }
}

fn check_box(
  coord: Coord,
  map: Dict(Coord, Tile),
  delta: Coord,
  acc: List(Coord),
) -> Result(List(Coord), Nil) {
  let beyond = coord.go(coord, delta)
  case dict.get(map, beyond) {
    Ok(Nothing) -> Ok([beyond, ..acc])
    Ok(Box) -> check_box(coord.go(coord, delta), map, delta, [beyond, ..acc])
    Ok(Wall) -> Error(Nil)
    _ -> panic as "ran out of things to check beyond box"
  }
}

fn move_boxes_simple(
  boxes: List(Coord),
  map: Dict(Coord, Tile),
  current: Coord,
  destination: Coord,
  next_steps: List(Direction),
) -> Dict(Coord, Tile) {
  list.fold(boxes, map, fn(acc, b) { dict.insert(acc, b, Box) })
  |> dict.insert(current, Nothing)
  |> dict.insert(destination, Robot)
  |> next_step_simple(destination, _, next_steps)
}

pub fn pt_1(input: String) {
  let assert [map, steps] = string.split(input, "\n\n")
  let map = parse_map(map)
  let steps = parse_steps(steps)

  let assert [robot] = dict.filter(map, fn(_, v) { v == Robot }) |> dict.keys

  next_step_simple(robot, map, steps)
  |> dict.fold(0, fn(acc, k, v) {
    case v {
      Box -> k.c + 100 * k.r + acc
      _ -> acc
    }
  })
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
  case dict.get(map, maybe) {
    Ok(Nothing) ->
      map
      |> dict.insert(robot, Nothing)
      |> dict.insert(maybe, Robot)
      |> next_step(maybe, _, rest)
    Ok(LeftBox) | Ok(RightBox) -> {
      let boxes = case next {
        Left | Right ->
          check_double_box_horiz(robot, map, delta, [#(robot, Robot)])
        Up | Down ->
          check_double_box_vert(robot, map, delta, Ok([#(robot, Robot)]))
      }
      case boxes {
        Ok(found_boxes) -> move_boxes(found_boxes, map, maybe, rest, delta)
        Error(_) -> next_step(robot, map, rest)
      }
    }
    Ok(Wall) -> next_step(robot, map, rest)
    Ok(Robot) -> panic as "robot has achieved enlightenment by finding itself"
    _ -> panic as "robot left the grid somehow"
  }
}

fn check_double_box_horiz(
  coord: Coord,
  map: Dict(Coord, Tile),
  delta: Coord,
  acc: List(#(Coord, Tile)),
) -> Result(List(#(Coord, Tile)), Nil) {
  let beyond = coord.go(coord, delta)
  let assert Ok(tile) = dict.get(map, coord)
  case dict.get(map, beyond) {
    Ok(Nothing) -> Ok([#(coord, tile), ..acc])
    Ok(LeftBox) | Ok(RightBox) ->
      check_double_box_horiz(beyond, map, delta, [#(coord, tile), ..acc])
    Ok(Wall) -> Error(Nil)
    _ -> panic as "ran out of things to check beyond box horizontally"
  }
}

fn check_double_box_vert(
  coord: Coord,
  map: Dict(Coord, Tile),
  delta: Coord,
  acc: Result(List(#(Coord, Tile)), Nil),
) -> Result(List(#(Coord, Tile)), Nil) {
  let beyond = coord.go(coord, delta)
  let assert Ok(tile) = dict.get(map, coord)
  case dict.get(map, beyond) {
    Ok(Nothing) ->
      result.map(acc, fn(b) { list.prepend(b, #(coord, tile)) |> list.unique })
    Ok(LeftBox as kind) | Ok(RightBox as kind) -> {
      let dir = case kind {
        LeftBox -> Right
        RightBox -> Left
        _ -> panic
      }
      list.try_map([beyond, coord.go(beyond, to_delta(dir))], fn(b) {
        let assert Ok(t) = dict.get(map, b)
        result.map(acc, list.prepend(_, #(b, t)))
        |> check_double_box_vert(b, map, delta, _)
      })
      |> result.map(list.flatten)
    }
    Ok(Wall) -> Error(Nil)
    _ -> panic as "ran out of things to check beyond box vertically:"
  }
}

fn move_boxes(
  boxes: List(#(Coord, Tile)),
  map: Dict(Coord, Tile),
  destination: Coord,
  next_steps: List(Direction),
  delta: Coord,
) -> Dict(Coord, Tile) {
  list.append(
    list.map(boxes, fn(b) { #(b.0, Nothing) }),
    list.map(boxes, fn(b) { #(coord.go(b.0, delta), b.1) }),
  )
  |> list.fold(map, fn(acc, b) { dict.insert(acc, b.0, b.1) })
  |> next_step(destination, _, next_steps)
}

fn preprocess(input: String) {
  input
  |> string.split("\n")
  |> list.map(preprocess_line)
  |> string.join("\n")
}

fn preprocess_line(line: String) {
  case line {
    "" -> ""
    "@" <> rest -> "@." <> preprocess_line(rest)
    "." <> rest -> ".." <> preprocess_line(rest)
    "O" <> rest -> "[]" <> preprocess_line(rest)
    "#" <> rest -> "##" <> preprocess_line(rest)
    _ -> panic as { "unexpected object" <> line }
  }
}

pub fn pt_2(input: String) {
  let assert [map, steps] = string.split(input, "\n\n")
  let map = map |> preprocess |> parse_map

  let assert [robot] = dict.filter(map, fn(_, v) { v == Robot }) |> dict.keys
  let steps = parse_steps(steps)

  next_step(robot, map, steps)
  |> dict.fold(0, fn(acc, k, v) {
    case v {
      LeftBox -> k.c + 100 * k.r + acc
      _ -> acc
    }
  })
}

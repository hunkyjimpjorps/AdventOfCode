import gleam/int
import gleam/list
import gleam/string

pub type Direction {
  North
  Northeast
  Northwest
  South
  Southeast
  Southwest
}

type HexPosition {
  HexPosition(x: Int, y: Int, z: Int)
}

const start = HexPosition(0, 0, 0)

fn to_direction(str: String) -> Direction {
  case str {
    "n" -> North
    "ne" -> Northeast
    "nw" -> Northwest
    "s" -> South
    "se" -> Southeast
    "sw" -> Southwest
    _ -> panic as "unrecognized direction"
  }
}

fn distance(hp1: HexPosition, hp2: HexPosition) -> Int {
  {
    int.absolute_value(hp1.x - hp2.x)
    + int.absolute_value(hp1.y - hp2.y)
    + int.absolute_value(hp1.z - hp2.z)
  }
  / 2
}

fn move(p, direction) -> HexPosition {
  case direction {
    North -> HexPosition(..p, y: p.y + 1, z: p.z - 1)
    South -> HexPosition(..p, y: p.y - 1, z: p.z + 1)
    Northeast -> HexPosition(..p, x: p.x + 1, z: p.z - 1)
    Southwest -> HexPosition(..p, x: p.x - 1, z: p.z + 1)
    Southeast -> HexPosition(..p, x: p.x + 1, y: p.y - 1)
    Northwest -> HexPosition(..p, x: p.x - 1, y: p.y + 1)
  }
}

pub fn parse(input: String) -> List(Direction) {
  input
  |> string.split(",")
  |> list.map(to_direction)
}

pub fn pt_1(input: List(Direction)) {
  do_walk(input, start, 0).0
}

pub fn pt_2(input: List(Direction)) {
  do_walk(input, start, 0).1
}

fn do_walk(steps, position, max) {
  case steps {
    [] -> #(distance(position, HexPosition(0, 0, 0)), max)
    [next, ..rest] -> {
      let new_position = move(position, next)
      let new_max = int.max(max, distance(new_position, start))
      do_walk(rest, new_position, new_max)
    }
  }
}

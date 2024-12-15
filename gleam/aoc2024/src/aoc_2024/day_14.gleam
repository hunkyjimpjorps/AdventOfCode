import gleam/dict
import gleam/int
import gleam/list
import gleam/option
import gleam/regexp
import gleam/result
import gleam/string
import my_utils/to
import my_utils/xy.{type XY, XY}

pub type Robot {
  Robot(posn: XY, velocity: XY)
}

const h_size = 101

const v_size = 103

fn go_wrap(a: XY, delta: XY) {
  XY(
    result.unwrap(int.modulo(a.x + delta.x, h_size), 0),
    result.unwrap(int.modulo(a.y + delta.y, v_size), 0),
  )
}

pub fn parse(input: String) {
  use line <- list.map(string.split(input, "\n"))
  let assert Ok(re) = regexp.from_string("p=(\\d+),(\\d+) v=(-?\\d+),(-?\\d+)")

  let assert [regexp.Match(submatches: submatches, ..)] = regexp.scan(re, line)
  let assert [px, py, vx, vy] = submatches |> option.values |> list.map(to.int)
  Robot(XY(px, py), XY(vx, vy))
}

fn to_time(robot: Robot, time: Int) {
  let total_move = XY(robot.velocity.x * time, robot.velocity.y * time)
  Robot(..robot, posn: go_wrap(robot.posn, total_move))
}

fn step(robot: Robot) {
  Robot(..robot, posn: go_wrap(robot.posn, robot.velocity))
}

fn classify(robot: Robot) {
  let h_mid = h_size / 2
  let v_mid = v_size / 2
  case robot.posn {
    XY(x, y) if x == h_mid || y == v_mid -> Error(Nil)
    XY(x, y) if x > h_mid && y < v_mid -> Ok(1)
    XY(x, y) if x < h_mid && y < v_mid -> Ok(2)
    XY(x, y) if x > h_mid && y > v_mid -> Ok(3)
    XY(x, y) if x < h_mid && y > v_mid -> Ok(4)
    _ -> panic
  }
}

pub fn pt_1(input: List(Robot)) {
  input
  |> list.map(to_time(_, 100))
  |> list.group(classify)
  |> dict.delete(Error(Nil))
  |> dict.fold(1, fn(acc, _, v) { acc * list.length(v) })
}

fn security_footage(robots: List(Robot)) {
  // finding when no drones overlap produces the tree
  robots
  |> list.map(fn(r) { r.posn })
  |> list.group(fn(posn) { posn })
  |> dict.map_values(fn(_, v) { list.length(v) })
  |> dict.values
  |> list.any(fn(v) { v > 1 })
}

pub fn pt_2(input: List(Robot)) {
  list.try_fold(list.range(0, 10_000), input, fn(acc, i) {
    case security_footage(acc) {
      True -> Ok(list.map(acc, step))
      False -> Error(i)
    }
  })
  |> result.unwrap_error(0)
}

import gleam/bool
import gleam/dict
import gleam/int
import gleam/list
import gleam/option
import gleam/regexp
import gleam/result
import gleam/string
import my_utils/to
import my_utils/xy.{type XY, XY}
import simplifile

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
  list.fold(list.range(1, 100), input, fn(acc, _) { list.map(acc, step) })
  |> list.group(classify)
  |> dict.delete(Error(Nil))
  |> dict.values
  |> list.fold(1, fn(acc, xs) { acc * list.length(xs) })
}

const path = "./day_14_output.txt"

fn security_footage(robots: List(Robot), sec: Int) {
  let current =
    robots
    |> list.map(fn(r) { r.posn })
    |> list.group(fn(posn) { posn })
    |> dict.map_values(fn(_, v) { list.length(v) })

  use <- bool.guard(current |> dict.values |> list.any(fn(v) { v > 1 }), Nil)
  let chrs = {
    use y <- list.map(list.range(0, v_size - 1))
    use x <- list.map(list.range(0, h_size - 1))
    case dict.get(current, XY(x, y)) {
      Error(_) -> " "
      Ok(_) -> "█"
    }
  }

  let footage = chrs |> list.map(string.concat) |> string.join("\n")
  let _ =
    simplifile.append(
      path,
      "Second " <> int.to_string(sec) <> "\n" <> footage <> "\n\n\n",
    )

  Nil
}

pub fn pt_2(input: List(Robot)) {
  let _ = simplifile.delete(path)
  let _ = simplifile.create_file(path)

  list.fold(list.range(1, 10_000), input, fn(acc, sec) {
    let next = list.map(acc, step)
    security_footage(next, sec)

    next
  })

  let assert Ok(["Second " <> answer, ..]) =
    simplifile.read(from: path) |> result.map(string.split(_, "\n"))
  to.int(answer)
}

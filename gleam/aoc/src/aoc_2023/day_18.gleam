import gleam/int
import gleam/list
import gleam/option.{Some}
import gleam/regexp.{Match}
import gleam/string
import my_utils/xy.{type XY, XY}

type Direction {
  Up
  Right
  Down
  Left
}

type Dig {
  Dig(dir: Direction, dist: Int)
}

fn to_direction(c: String) {
  case c {
    "R" | "0" -> Right
    "D" | "1" -> Down
    "L" | "2" -> Left
    "U" | "3" -> Up
    _ -> panic
  }
}

fn parse_front(line: String) {
  let assert Ok(re) = regexp.from_string("(.) (.*) \\(.*\\)")
  let assert [Match(submatches: [Some(dir), Some(dist)], ..)] =
    regexp.scan(with: re, content: line)
  let assert Ok(n) = int.parse(dist)
  Dig(to_direction(dir), n)
}

fn parse_hex(line: String) {
  let assert Ok(re) = regexp.from_string("\\(#(.....)(.)\\)")
  let assert [Match(submatches: [Some(dist), Some(dir)], ..)] =
    regexp.scan(with: re, content: line)
  let assert Ok(n) = int.base_parse(dist, 16)
  Dig(to_direction(dir), n)
}

fn go(current: XY, dig: Dig) {
  case dig {
    Dig(Up, n) -> XY(current.x, current.y + n)
    Dig(Right, n) -> XY(current.x + n, current.y)
    Dig(Down, n) -> XY(current.x, current.y - n)
    Dig(Left, n) -> XY(current.x - n, current.y)
  }
}

fn double_triangle(c1: XY, c2: XY) {
  { c1.x * c2.y } - { c2.x * c1.y }
}

fn start_dig(digs: List(Dig)) {
  do_next_dig(digs, XY(0, 0), 0, 0)
}

fn do_next_dig(digs: List(Dig), current: XY, area: Int, perimeter: Int) -> Int {
  case digs {
    [] -> int.absolute_value(area) / 2 + { perimeter / 2 } + 1
    [dig, ..rest] -> {
      let next = go(current, dig)
      let area = area + double_triangle(current, next)
      let perimeter = perimeter + dig.dist
      do_next_dig(rest, next, area, perimeter)
    }
  }
}

fn solve_with(input, f) {
  input
  |> string.split("\n")
  |> list.map(f)
  |> start_dig
}

pub fn pt_1(input: String) {
  solve_with(input, parse_front)
}

pub fn pt_2(input: String) {
  solve_with(input, parse_hex)
}

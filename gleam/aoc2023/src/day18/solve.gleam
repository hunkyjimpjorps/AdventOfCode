import adglent.{First, Second}
import gleam/io
import gleam/int
import gleam/list
import gleam/option.{Some}
import gleam/regex.{type Match, Match}
import gleam/string

type Coord {
  Coord(x: Int, y: Int)
}

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
  let assert Ok(re) = regex.from_string("(.) (.*) \\(.*\\)")
  let assert [Match(submatches: [Some(dir), Some(dist)], ..)] =
    regex.scan(with: re, content: line)
  let assert Ok(n) = int.parse(dist)
  Dig(to_direction(dir), n)
}

fn parse_hex(line: String) {
  let assert Ok(re) = regex.from_string("\\(#(.....)(.)\\)")
  let assert [Match(submatches: [Some(dist), Some(dir)], ..)] =
    regex.scan(with: re, content: line)
  let assert Ok(n) = int.base_parse(dist, 16)
  Dig(to_direction(dir), n)
}

fn go(current: Coord, dig: Dig) {
  case dig {
    Dig(Up, n) -> Coord(current.x, current.y + n)
    Dig(Right, n) -> Coord(current.x + n, current.y)
    Dig(Down, n) -> Coord(current.x, current.y - n)
    Dig(Left, n) -> Coord(current.x - n, current.y)
  }
}

fn double_triangle(c1: Coord, c2: Coord) {
  { c1.x * c2.y } - { c2.x * c1.y }
}

fn start_dig(digs: List(Dig)) {
  do_next_dig(digs, Coord(0, 0), 0, 0)
}

fn do_next_dig(
  digs: List(Dig),
  current: Coord,
  area: Int,
  perimeter: Int,
) -> Int {
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
  |> string.inspect
}

pub fn part1(input: String) {
  solve_with(input, parse_front)
}

pub fn part2(input: String) {
  solve_with(input, parse_hex)
}

pub fn main() {
  let assert Ok(part) = adglent.get_part()
  let assert Ok(input) = adglent.get_input("18")
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

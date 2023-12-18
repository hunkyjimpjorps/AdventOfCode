import adglent.{First, Second}
import gleam/io
import utilities/array2d.{type Posn, Posn}

type Direction {
  North
  South
  East
  West
}

fn turn_dirs(dir: Direction) {
  case dir {
    North | South -> [East, West]
    East | West -> [North, South]
  }
}

fn delta(dir: Direction) {
  case dir {
    North -> Posn(-1, 0)
    South -> Posn(1, 0)
    East -> Posn(0, 1)
    West -> Posn(0, -1)
  }
}

pub fn part1(input: String) {
  todo as "Implement solution to part 1"
}

pub fn part2(input: String) {
  todo as "Implement solution to part 2"
}

pub fn main() {
  let assert Ok(part) = adglent.get_part()
  let assert Ok(input) = adglent.get_input("17")
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

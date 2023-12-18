import adglent.{First, Second}
import gleam/io
import gleam/string
import utilities/array2d.{type Posn, Posn}

pub fn part1(input: String) {
  input
  |> array2d.parse_grid
  |> string.inspect
}

pub fn part2(input: String) {
  input
  |> string.inspect
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

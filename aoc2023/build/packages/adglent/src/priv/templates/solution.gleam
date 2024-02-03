pub const template = "
import adglent.{First, Second}
import gleam/io

pub fn part1(input: String) {
  todo as \"Implement solution to part 1\"
}

pub fn part2(input: String) {
  todo as \"Implement solution to part 2\"
}

pub fn main() {
  let assert Ok(part) = adglent.get_part()
  let assert Ok(input) = adglent.get_input(\"{{ day }}\")
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
"

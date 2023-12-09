import adglent.{First, Second}
import gleam/io
import gleam/int
import gleam/string
import gleam/list

pub type Game {
  Game(red: Int, blue: Int, green: Int)
}

fn parse(input: String) -> List(List(Game)) {
  use line <- list.map(string.split(input, "\n"))
  let assert [_, rounds] = string.split(line, on: ": ")
  use match <- list.map(string.split(rounds, on: "; "))
  use acc, draw <- list.fold(
    over: string.split(match, on: ", "),
    from: Game(0, 0, 0),
  )
  let assert Ok(#(n_str, color)) = string.split_once(draw, " ")
  let assert Ok(n) = int.parse(n_str)
  case color {
    "red" -> Game(..acc, red: n)
    "blue" -> Game(..acc, blue: n)
    "green" -> Game(..acc, green: n)
    _ -> panic as { "unrecognized color " <> color }
  }
}

pub fn part1(input: String) {
  use acc, game, i <- list.index_fold(parse(input), 0)
  case list.any(game, fn(m) { m.red > 12 || m.green > 13 || m.blue > 14 }) {
    False -> acc + i + 1
    True -> acc
  }
}

pub fn part2(input: String) {
  {
    use game <- list.map(parse(input))
    use acc, match <- list.fold(game, Game(0, 0, 0))
    let Game(red: red, green: green, blue: blue) = match
    Game(
      red: int.max(red, acc.red),
      blue: int.max(blue, acc.blue),
      green: int.max(green, acc.green),
    )
  }
  |> list.fold(from: 0, with: fn(acc, g: Game) {
    acc + g.red * g.blue * g.green
  })
}

pub fn main() {
  let assert Ok(part) = adglent.get_part()
  let assert Ok(input) = adglent.get_input("2")
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

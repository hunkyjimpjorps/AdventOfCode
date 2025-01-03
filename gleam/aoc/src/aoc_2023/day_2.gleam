import gleam/int
import gleam/list
import gleam/string

pub type Game {
  Game(red: Int, blue: Int, green: Int)
}

pub fn parse(input: String) -> List(List(Game)) {
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
    _ -> panic as "unrecognized color"
  }
}

pub fn pt_1(input: List(List(Game))) {
  use acc, game, i <- list.index_fold(input, 0)
  case list.any(game, fn(m) { m.red > 12 || m.green > 13 || m.blue > 14 }) {
    False -> acc + i + 1
    True -> acc
  }
}

pub fn pt_2(input: List(List(Game))) {
  {
    use game <- list.map(input)
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

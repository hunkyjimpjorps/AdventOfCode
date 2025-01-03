import gleam/int
import gleam/list
import gleam/string

fn look_and_say(previous: String) {
  previous
  |> string.to_graphemes
  |> list.chunk(fn(n) { n })
  |> list.map(fn(xs) {
    case xs {
      [] -> ""
      [n] -> "1" <> n
      [n, ..] as ns -> { ns |> list.length |> int.to_string } <> n
    }
  })
  |> string.concat
}

fn repeatedly_look_and_say(starting: String, iteration: Int) {
  case iteration {
    0 -> starting
    n -> repeatedly_look_and_say(look_and_say(starting), n - 1)
  }
}

pub fn pt_1(input: String) {
  repeatedly_look_and_say(input, 40) |> string.length
}

pub fn pt_2(input: String) {
  repeatedly_look_and_say(input, 50) |> string.length
}

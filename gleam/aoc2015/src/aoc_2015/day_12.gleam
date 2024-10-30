import gleam/dict
import gleam/dynamic.{type Dynamic}
import gleam/int
import gleam/io
import gleam/json
import gleam/list
import gleam/regex
import gleam/result

pub fn pt_1(input: String) {
  let assert Ok(not_digits) = regex.from_string("[^0-9\\-]")

  input
  |> regex.split(with: not_digits)
  |> list.filter_map(int.parse)
  |> int.sum()
}

pub fn pt_2(input: String) {
  input |> json.decode(using: dynamic.list(or)) |> result.map(int.sum)
}

fn or(value: Dynamic) {
  case dynamic.classify(value) |> io.debug() {
    "Int" -> dynamic.int(value)
    "List" -> value |> dynamic.list(of: or) |> result.map(int.sum)
    "Dict" -> {
      let assert Ok(dict) =
        value |> dynamic.dict(dynamic.dynamic, dynamic.dynamic)
      case dict |> dict.values |> list.contains("red" |> dynamic.from) {
        True -> Ok(0)
        False ->
          dict
          |> dict.values()
          |> list.try_map(or)
          |> result.map(int.sum)
      }
    }
    _ -> Ok(0)
  }
}

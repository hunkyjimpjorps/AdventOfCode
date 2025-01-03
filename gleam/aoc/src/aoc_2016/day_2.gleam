import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import my_utils/xy.{type XY, XY}

pub type Move {
  Up
  Down
  Left
  Right
  Press
}

pub fn parse(input: String) {
  do_parse(input, [])
}

fn do_parse(input: String, acc: List(Move)) {
  case string.pop_grapheme(input) {
    Error(_) -> list.reverse([Press, ..acc])
    Ok(#(c, rest)) ->
      case c {
        "U" -> Up
        "D" -> Down
        "L" -> Left
        "R" -> Right
        "\n" -> Press
        _ -> panic
      }
      |> list.prepend(acc, _)
      |> do_parse(rest, _)
  }
}

fn move(current: XY, move) {
  case move {
    Up -> XY(current.x, current.y - 1)
    Down -> XY(current.x, current.y + 1)
    Left -> XY(current.x - 1, current.y)
    Right -> XY(current.x + 1, current.y)
    _ -> current
  }
}

fn get_code(current, moves, acc, buttons) {
  case moves {
    [] -> list.reverse(acc)
    [Press, ..rest] ->
      get_code(current, rest, [dict.get(buttons, current), ..acc], buttons)
    [dir, ..rest] -> {
      case dict.get(buttons, move(current, dir)) |> io.debug {
        Error(..) -> get_code(current, rest, acc, buttons)
        Ok(_) -> get_code(move(current, dir), rest, acc, buttons)
      }
    }
  }
}

fn simple_pad() {
  list.range(1, 9)
  |> list.map(fn(n) { #(XY({ { n - 1 } % 3 } + 1, { n - 1 } / 3 + 1), n) })
  |> dict.from_list
}

pub fn pt_1(input: List(Move)) {
  get_code(XY(2, 2), input, [], simple_pad())
  |> result.values
  |> int.undigits(10)
  |> result.unwrap(0)
}

fn fancy_pad() {
  [
    #(XY(3, 1), 1),
    #(XY(2, 2), 2),
    #(XY(3, 2), 3),
    #(XY(4, 2), 4),
    #(XY(1, 3), 5),
    #(XY(2, 3), 6),
    #(XY(3, 3), 7),
    #(XY(4, 3), 8),
    #(XY(5, 3), 9),
    #(XY(2, 4), 10),
    #(XY(3, 4), 11),
    #(XY(4, 4), 12),
    #(XY(3, 5), 13),
  ]
  |> dict.from_list
}

pub fn pt_2(input: List(Move)) {
  get_code(XY(1, 3), input, [], fancy_pad())
  |> result.values
  |> int.undigits(16)
  |> result.try(int.to_base_string(_, 16))
  |> result.unwrap("")
}

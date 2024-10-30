import gleam/list
import gleam/string

const a_int = 97

const i_int = 105

const l_int = 108

const o_int = 111

const z_int = 122

fn to_digits(str: String) {
  str
  |> string.to_utf_codepoints
  |> list.map(string.utf_codepoint_to_int)
  |> list.reverse
}

fn from_digits(digits: List(Int)) {
  digits
  |> list.reverse
  |> list.filter_map(string.utf_codepoint)
  |> string.from_utf_codepoints
}

fn increment(digits: List(Int)) {
  case digits {
    [z, ..rest] if z == z_int -> [a_int, ..increment(rest)]
    [letter, ..rest] -> [letter + 1, ..rest]
    [] -> panic as "ran out of passwords"
  }
}

fn meets_rule_1(digits: List(Int)) {
  digits
  |> list.window_by_2
  |> list.map(fn(tup) { tup.0 - tup.1 })
  |> list.window_by_2
  |> list.contains(#(1, 1))
}

fn meets_rule_2(digits: List(Int)) {
  !list.any(digits, fn(digit) {
    digit == i_int || digit == o_int || digit == l_int
  })
}

fn meets_rule_3(digits: List(Int)) {
  let dupes =
    digits
    |> list.chunk(fn(x) { x })
    |> list.filter_map(fn(xs) {
      case xs {
        [] | [_] -> Error(Nil)
        [n, ..] -> Ok(n)
      }
    })
    |> list.unique

  list.length(dupes) >= 2
}

fn find_next_password(digits: List(Int)) {
  case meets_rule_1(digits) && meets_rule_2(digits) && meets_rule_3(digits) {
    True -> from_digits(digits)
    False -> digits |> increment |> find_next_password
  }
}

pub fn pt_1(input: String) {
  input
  |> to_digits
  |> find_next_password
}

pub fn pt_2(input: String) {
  input
  |> to_digits
  |> find_next_password
  |> to_digits
  |> increment
  |> find_next_password
}

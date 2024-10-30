import gleam/int
import gleam/list
import gleam/string

fn get_character_count(chrs: List(String)) {
  case chrs {
    [] -> 0
    ["\"", ..rest] -> get_character_count(rest)
    ["\\", "x", _, _, ..rest] | ["\\", _, ..rest] | [_, ..rest] ->
      1 + get_character_count(rest)
  }
}

fn get_encoded_size(chrs: List(String)) {
  case chrs {
    [] -> 2
    ["\"", ..rest] | ["\\", ..rest] -> 2 + get_encoded_size(rest)
    [_, ..rest] -> 1 + get_encoded_size(rest)
  }
}

fn pt1_difference(str: String) {
  let character_count = str |> string.to_graphemes |> get_character_count
  string.length(str) - character_count
}

pub fn pt_1(input: String) {
  input |> string.split("\n") |> list.map(pt1_difference) |> int.sum
}

fn pt2_difference(str: String) {
  let encoded_size = str |> string.to_graphemes |> get_encoded_size
  encoded_size - string.length(str)
}

pub fn pt_2(input: String) {
  input |> string.split("\n") |> list.map(pt2_difference) |> int.sum
}

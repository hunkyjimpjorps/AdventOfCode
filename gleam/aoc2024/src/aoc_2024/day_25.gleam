import gleam/list
import gleam/string

type Parsed =
  #(List(List(Int)), List(List(Int)))

fn to_heights(input: String) {
  input
  |> string.split("\n")
  |> list.map(string.to_graphemes)
  |> list.transpose
  |> list.map(fn(s) { list.count(s, fn(c) { c == "#" }) - 1 })
}

pub fn parse(input: String) -> #(List(List(Int)), List(List(Int))) {
  let raw_schematics = string.split(input, "\n\n")
  let #(raw_locks, raw_keys) =
    list.partition(raw_schematics, string.starts_with(_, "#"))

  #(list.map(raw_locks, to_heights), list.map(raw_keys, to_heights))
}

pub fn pt_1(input: Parsed) {
  let #(locks, keys) = input

  use outer_acc, l <- list.fold(locks, 0)
  use inner_acc, k <- list.fold(keys, outer_acc)
  case list.zip(l, k) |> list.all(fn(tup) { tup.0 + tup.1 <= 5 }) {
    True -> inner_acc + 1
    False -> inner_acc
  }
}

pub fn pt_2(_input: Parsed) {
  "Merry Christmas!"
}

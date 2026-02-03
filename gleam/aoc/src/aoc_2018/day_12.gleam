import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/order
import gleam/result
import gleam/string

type Parsed =
  #(Dict(Int, Plant), Dict(List(Plant), Plant))

pub type Plant {
  Filled
  Empty
}

fn id_plant(ch: String) -> Plant {
  case ch {
    "#" -> Filled
    "." -> Empty
    _ -> panic as "unrecognized plant"
  }
}

fn parse_line(line: String) -> #(List(Plant), Plant) {
  let assert [state, result] = string.split(line, " => ")
  #(state |> string.to_graphemes |> list.map(id_plant), id_plant(result))
}

pub fn parse(input: String) -> Parsed {
  let assert [state, rules] = string.split(input, "\n\n")

  let assert "initial state: " <> plants = state
  let plants =
    plants
    |> string.to_graphemes
    |> list.index_map(fn(c, i) { #(i, id_plant(c)) })
    |> dict.from_list

  let rules =
    rules
    |> string.split("\n")
    |> list.map(parse_line)
    |> dict.from_list

  #(plants, rules)
}

fn next_step(current, rules) {
  let keys = dict.keys(current)
  let assert Ok(from) = list.max(keys, order.reverse(int.compare))
  let assert Ok(to) = list.max(keys, int.compare)

  use acc, index <- list.fold(
    over: list.range(from - 2, to + 2),
    from: dict.new(),
  )
  list.range(index - 2, index + 2)
  |> list.map(fn(i) { current |> dict.get(i) |> result.unwrap(Empty) })
  |> dict.get(rules, _)
  |> result.unwrap(Empty)
  |> dict.insert(acc, index, _)
}

fn score(plants) {
  plants
  |> dict.filter(fn(_, v) { v == Filled })
  |> dict.keys
  |> int.sum
}

pub fn pt_1(input: Parsed) {
  let #(plants, rules) = input
  list.range(1, 20)
  |> list.fold(plants, fn(acc, _) { next_step(acc, rules) })
  |> score
}

pub fn pt_2(input: Parsed) {
  let #(plants, rules) = input
  let start =
    list.fold(list.range(1, 200), plants, fn(acc, _) { next_step(acc, rules) })
  let end = next_step(start, rules)
  let diff = score(end) - score(start)

  score(start) + diff * { 50_000_000_000 - 200 }
}

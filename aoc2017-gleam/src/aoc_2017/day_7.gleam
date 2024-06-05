import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option.{Some}
import gleam/regex.{type Match, Match}
import gleam/set
import gleam/string

pub type Program {
  Program(name: String, weight: Int, supporting: List(String))
}

pub fn parse(input: String) {
  let assert Ok(re) = regex.from_string("([a-z]+) \\(([0-9]+)\\)(?> -> (.*))?")

  use match <- list.map(string.split(input, "\n"))
  case regex.scan(re, match) {
    [Match(submatches: [Some(name), Some(weight)], ..)] ->
      Program(name, to_int(weight), [])
    [Match(submatches: [Some(name), Some(weight), Some(supporting)], ..)] ->
      Program(name, to_int(weight), string.split(supporting, ", "))
    _ -> panic as { "couldn't parse" <> match }
  }
}

fn to_int(str: String) -> Int {
  let assert Ok(n) = int.parse(str)
  n
}

pub fn pt_1(input: List(Program)) {
  let supporters = input |> list.map(fn(p) { p.name }) |> set.from_list()
  let supporting =
    input |> list.flat_map(fn(p) { p.supporting }) |> set.from_list()

  let assert [base] = set.difference(supporters, supporting) |> set.to_list
  base
}

pub fn pt_2(input: List(Program)) {
  let weights =
    input |> list.map(fn(p) { #(p.name, p.weight) }) |> dict.from_list

  let supporters =
    input
    |> list.filter_map(fn(p) {
      case list.is_empty(p.supporting) {
        True -> Error(Nil)
        False -> Ok(#(p.name, p.supporting))
      }
    })
    |> dict.from_list

  supporters
  |> dict.keys()
  |> list.filter_map(fn(name) {
    let branch_weights =
      name
      |> branch_weights(weights, supporters)
      |> fn(tup: #(String, List(#(Int, String)))) { tup.1 }

    case
      branch_weights
      |> list.map(fn(tup: #(Int, String)) { tup.0 })
      |> list.unique
      |> list.length
    {
      2 -> Ok(#(name, branch_weights))
      _ -> Error(Nil)
    }
  })

  // [
  //  #("hmgrlpj", [#(2078, "drjmjug"), #(2070, "nigdlq"), #(2070, "omytneg"), ...]), 
  //  #("smaygo", [#(14564, "hmgrlpj"), #(14556, "fbnbt"), #(14556, "nfdvsc")])
  //  #("eugwuhl", [#(48292, "smaygo"), #(48284, "pvvbn"), #(48284, "hgizeb"), ...]),
  // ]
  //
  // by inspection, eugwuhl -> smaygo -> hmgrlpj -> drjmjug; changing drjmjug will fix the tower

  let assert Ok(w) = dict.get(weights, "drjmjug")
  w - 8
}

fn branch_weights(
  name: String,
  weights: Dict(String, Int),
  supporting: Dict(String, List(String)),
) -> #(String, List(#(Int, String))) {
  let supported = case dict.get(supporting, name) {
    Ok(supported) -> supported
    Error(_) -> []
  }

  let supported_weights =
    list.map(supported, fn(s) {
      let assert Ok(weight) = dict.get(weights, s)
      let children_weights =
        s
        |> branch_weights(weights, supporting)
        |> fn(tup: #(String, List(#(Int, String)))) { tup.1 }
        |> list.map(fn(tup: #(Int, String)) { tup.0 })
      weight + int.sum(children_weights)
    })
    |> list.zip(supported)

  #(name, supported_weights)
}

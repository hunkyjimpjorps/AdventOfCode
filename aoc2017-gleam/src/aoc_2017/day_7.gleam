import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
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
  todo as "part 2 not implemented"
}

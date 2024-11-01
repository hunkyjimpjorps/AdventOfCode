import gleam/dict
import gleam/int
import gleam/list
import gleam/string

const ticker_tape = "children: 3
cats: 7
samoyeds: 2
pomeranians: 3
akitas: 0
vizslas: 0
goldfish: 5
trees: 3
cars: 2
perfumes: 1"

fn parse_evidence(facts: String) {
  let assert Ok(#(evidence, number)) = facts |> string.split_once(": ")
  let assert Ok(n) = int.parse(number)
  #(evidence, n)
}

fn parse_ticker_tape(tape: String) {
  tape
  |> string.split("\n")
  |> list.map(parse_evidence)
  |> dict.from_list
}

fn parse_aunt(aunt: String) {
  let assert "Sue " <> info = aunt
  let assert Ok(#(number, rest)) = string.split_once(info, ": ")
  let assert Ok(n) = int.parse(number)
  let facts = string.split(rest, ", ") |> list.map(parse_evidence)
  #(n, dict.from_list(facts))
}

fn parse_aunts(input: String) {
  input |> string.split("\n") |> list.map(parse_aunt) |> dict.from_list
}

fn compare_facts(aunt_facts, ticker_tape, compare_with) {
  let overlapping_facts = dict.take(ticker_tape, dict.keys(aunt_facts))

  use acc, k, tape_v <- dict.fold(overlapping_facts, True)
  let assert Ok(aunt_v) = dict.get(aunt_facts, k)
  case acc {
    True -> compare_with(k, aunt_v, tape_v)
    False -> False
  }
}

pub fn pt_1(input: String) {
  let aunts = parse_aunts(input)
  let facts = parse_ticker_tape(ticker_tape)

  use _k, v <- dict.filter(aunts)
  use _fact, aunt, tape <- compare_facts(v, facts)
  aunt == tape
}

pub fn pt_2(input: String) {
  let aunts = parse_aunts(input)
  let facts = parse_ticker_tape(ticker_tape)

  use _k, v <- dict.filter(aunts)
  use fact, aunt, tape <- compare_facts(v, facts)
  case fact {
    "cats" | "trees" -> aunt > tape
    "goldfish" | "pomeranians" -> aunt < tape
    _ -> aunt == tape
  }
}

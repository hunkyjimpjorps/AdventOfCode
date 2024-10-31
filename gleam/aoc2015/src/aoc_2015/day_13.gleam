import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option.{Some}
import gleam/regex.{Match}
import gleam/result
import gleam/string

fn parse_pairing(line: String) {
  let assert Ok(re) =
    regex.from_string(
      "^(.*) would (gain|lose) (\\d+) happiness units by sitting next to (.*).$",
    )

  let assert [Match(_, [Some(first), Some(delta), Some(amount), Some(second)])] =
    regex.scan(line, with: re)

  #(#(first, second), happiness(delta, amount))
}

fn happiness(delta: String, amount: String) {
  let assert Ok(n) = int.parse(amount)

  case delta {
    "gain" -> n
    "lose" -> -1 * n
    _ -> panic
  }
}

fn get_attendees(pairings: Dict(#(String, String), Int)) {
  pairings |> dict.keys |> list.map(fn(tup) { tup.0 }) |> list.unique
}

fn calculate_happiness(pairings, attendees) {
  attendees
  |> list.permutations
  |> list.map(fn(attendees) {
    let assert [first, ..] = attendees
    list.append(attendees, [first])
    |> list.window_by_2
    |> list.map(fn(pair) {
      let a = dict.get(pairings, pair) |> result.unwrap(0)
      let b = dict.get(pairings, #(pair.1, pair.0)) |> result.unwrap(0)
      a + b
    })
    |> int.sum
  })
  |> list.fold(0, int.max)
}

pub fn pt_1(input: String) {
  let pairings =
    input |> string.split("\n") |> list.map(parse_pairing) |> dict.from_list

  let attendees = get_attendees(pairings)

  calculate_happiness(pairings, attendees)
}

pub fn pt_2(input: String) {
  let pairings =
    input |> string.split("\n") |> list.map(parse_pairing) |> dict.from_list

  let attendees = ["me", ..get_attendees(pairings)]

  calculate_happiness(pairings, attendees)
}

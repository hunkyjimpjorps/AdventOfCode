import adglent.{First, Second}
import gleam/io
import gleam/list
import gleam/string
import gleam/regex.{type Match, Match}
import gleam/int

fn parse_digits(input: String) {
  let assert Ok(re) = regex.from_string("[1-9]")

  input
  |> string.split("\n")
  |> list.fold(0, fn(acc, s) {
    let matches = regex.scan(s, with: re)

    let assert Ok(Match(content: first, ..)) = list.first(matches)
    let assert Ok(Match(content: last, ..)) = list.last(matches)
    let assert Ok(i) = int.parse(first <> last)
    acc + i
  })
}

pub fn part1(input: String) {
  input
  |> parse_digits
  |> string.inspect
}

const substitutions = [
  #("one", "o1e"),
  #("two", "t2o"),
  #("three", "t3e"),
  #("four", "4"),
  #("five", "5e"),
  #("six", "6"),
  #("seven", "7n"),
  #("eight", "e8t"),
  #("nine", "n9e"),
]

pub fn part2(input: String) {
  list.fold(
    over: substitutions,
    from: input,
    with: fn(acc, sub) {
      let #(from, to) = sub
      string.replace(in: acc, each: from, with: to)
    },
  )
  |> part1
}

pub fn main() {
  let assert Ok(part) = adglent.get_part()
  let assert Ok(input) = adglent.get_input("1")
  case part {
    First ->
      part1(input)
      |> adglent.inspect
      |> io.println
    Second ->
      part2(input)
      |> adglent.inspect
      |> io.println
  }
}

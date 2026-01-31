import gleam/int
import gleam/list
import gleam/regexp.{Match}
import gleam/string

pub fn pt_1(input: String) {
  let assert Ok(re) = regexp.from_string("[1-9]")

  use acc, s <- list.fold(string.split(input, "\n"), 0)
  let matches = regexp.scan(s, with: re)

  let assert Ok(Match(content: first, ..)) = list.first(matches)
  let assert Ok(Match(content: last, ..)) = list.last(matches)
  let assert Ok(i) = int.parse(first <> last)
  acc + i
}

const substitutions = [
  #("one", "o1e"), #("two", "t2o"), #("three", "t3e"), #("four", "4"),
  #("five", "5e"), #("six", "6"), #("seven", "7n"), #("eight", "e8t"),
  #("nine", "n9e"),
]

pub fn pt_2(input: String) {
  list.fold(over: substitutions, from: input, with: fn(acc, sub) {
    let #(from, to) = sub
    string.replace(in: acc, each: from, with: to)
  })
  |> pt_1
}

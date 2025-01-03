import gleam/list
import gleam/string

pub fn parse(input: String) -> List(List(String)) {
  use row <- list.map(string.split(input, "\n"))
  string.split(row, " ")
}

pub fn pt_1(input: List(List(String))) {
  use acc, passwords <- list.fold(input, 0)
  case passwords == list.unique(passwords) {
    True -> acc + 1
    False -> acc
  }
}

pub fn pt_2(input: List(List(String))) {
  use acc, passwords <- list.fold(input, 0)
  let sorted_passwords = list.map(passwords, sort_graphemes)
  case sorted_passwords == list.unique(sorted_passwords) {
    True -> acc + 1
    False -> acc
  }
}

fn sort_graphemes(word: String) -> String {
  word
  |> string.to_graphemes
  |> list.sort(string.compare)
  |> string.concat
}

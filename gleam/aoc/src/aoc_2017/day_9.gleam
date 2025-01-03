import gleam/list
import gleam/option.{Some}
import gleam/regexp
import gleam/string

pub fn parse(input: String) {
  let assert Ok(cancel) = regexp.from_string("!.")

  replace(input, with: cancel)
}

pub fn pt_1(input: String) {
  input
  |> strip_to_brackets()
  |> next_bracket(0, 1)
}

fn replace(input: String, with regexp: regexp.Regexp) -> String {
  input |> regexp.split(with: regexp) |> string.concat()
}

fn strip_to_brackets(input: String) -> String {
  let assert Ok(garbage) = regexp.from_string("<.*?>")
  let assert Ok(not_group) = regexp.from_string("[^{}]")

  input
  |> replace(with: garbage)
  |> replace(with: not_group)
}

fn next_bracket(brackets: String, score: Int, depth: Int) -> Int {
  case string.pop_grapheme(brackets) {
    Error(Nil) -> score
    Ok(#("{", rest)) -> next_bracket(rest, score + depth, depth + 1)
    Ok(#("}", rest)) -> next_bracket(rest, score, depth - 1)
    _ -> panic as "unrecognized character"
  }
}

pub fn pt_2(input: String) {
  let assert Ok(garbage) = regexp.from_string("<(.*?)>")

  use acc, match <- list.fold(regexp.scan(input, with: garbage), 0)
  case match.submatches {
    [Some(g)] -> string.length(g) + acc
    _ -> acc
  }
}

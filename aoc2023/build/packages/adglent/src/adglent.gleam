import simplifile.{type FileError}
import gleam/list
import gleam/string

pub type Example(a) {
  Example(input: String, answer: a)
}

pub fn inspect(value: a) -> String {
  let inspected_value = string.inspect(value)
  case
    inspected_value
    |> string.starts_with("\"")
  {
    True ->
      inspected_value
      |> string.drop_left(1)
      |> string.drop_right(1)
    False -> inspected_value
  }
}

pub fn get_input(day: String) -> Result(String, FileError) {
  simplifile.read("src/day" <> day <> "/input.txt")
}

pub fn get_test_folder(day: String) -> String {
  "test/day" <> day
}

pub type Problem {
  First
  Second
}

pub fn get_part() -> Result(Problem, Nil) {
  case start_arguments() {
    ["1"] -> Ok(First)
    ["2"] -> Ok(Second)
    _ -> Error(Nil)
  }
}

pub fn start_arguments() -> List(String) {
  get_start_arguments()
  |> list.map(to_string)
}

type Charlist

/// Transform a charlist to a string
@external(erlang, "unicode", "characters_to_binary")
fn to_string(a: Charlist) -> String

@external(erlang, "init", "get_plain_arguments")
fn get_start_arguments() -> List(Charlist)

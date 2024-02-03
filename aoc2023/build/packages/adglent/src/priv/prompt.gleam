import gleam/result
import gleam/string

pub fn confirm(message: String, auto_accept: Bool) -> Bool {
  auto_accept || case
    get_line(message <> "? (Y/N): ")
    |> result.unwrap("n")
    |> string.trim()
  {
    "Y" | "y" -> True
    _ -> False
  }
}

pub fn value(message: String, default: String, auto_accept: Bool) -> String {
  case get_value_of_default(message, default, auto_accept) {
    "" -> default
    value -> value
  }
}

fn get_value_of_default(message: String, default: String, auto_accept: Bool) {
  case auto_accept {
    True -> default
    False ->
      get_line(message <> "? (" <> default <> "): ")
      |> result.unwrap("")
      |> string.trim()
  }
}

pub type GetLineError {
  Eof
  NoData
}

@external(erlang, "adglent_ffi", "get_line")
pub fn get_line(prompt prompt: String) -> Result(String, GetLineError)

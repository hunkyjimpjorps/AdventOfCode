import tom
import gleam/result

pub type TomError {
  TomParseError(error: tom.ParseError)
  TomGetError(error: tom.GetError)
}

pub fn get_string(
  toml_content: String,
  key_path: List(String),
) -> Result(String, TomError) {
  use toml <- result.try(
    tom.parse(toml_content <> "\n")
    |> result.map_error(TomParseError),
  )
  use value <- result.try(
    tom.get_string(toml, key_path)
    |> result.map_error(TomGetError),
  )
  Ok(value)
}

pub fn get_bool(
  toml_content: String,
  key_path: List(String),
) -> Result(Bool, TomError) {
  use toml <- result.try(
    tom.parse(toml_content <> "\n")
    |> result.map_error(TomParseError),
  )
  use value <- result.try(
    tom.get_bool(toml, key_path)
    |> result.map_error(TomGetError),
  )
  Ok(value)
}

pub fn get_int(
  toml_content: String,
  key_path: List(String),
) -> Result(Int, TomError) {
  use toml <- result.try(
    tom.parse(toml_content <> "\n")
    |> result.map_error(TomParseError),
  )
  use value <- result.try(
    tom.get_int(toml, key_path)
    |> result.map_error(TomGetError),
  )
  Ok(value)
}

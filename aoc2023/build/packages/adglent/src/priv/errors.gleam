import gleam/result
import gleam/string
import gleam/io

pub fn map_messages(
  result: Result(a, b),
  success_message: String,
  error_message: String,
) -> Result(String, String) {
  result
  |> result.map_error(fn(error) {
    "Error - " <> error_message <> ": " <> string.inspect(error)
  })
  |> result.replace(success_message)
}

pub fn map_error(
  result: Result(a, b),
  error_message: String,
) -> Result(a, String) {
  result
  |> result.map_error(fn(error) {
    error_message <> ": " <> string.inspect(error)
  })
}

pub fn print_result(result: Result(String, String)) {
  result
  |> result.unwrap_both
  |> io.println
  result
}

pub fn print_error(result: Result(a, String)) {
  result
  |> result.map_error(fn(err) {
    io.println(err)
    err
  })
}

pub fn assert_ok(result: Result(a, String)) {
  let assert Ok(value) =
    result
    |> result.map_error(fn(err) {
      halt(1)
      err
    })
  value
}

@target(erlang)
@external(erlang, "erlang", "halt")
fn halt(a: Int) -> Nil

import gleam/result.{try}
import gleam/httpc
import gleam/http/request
import gleam/int
import gleam/string

pub fn get_input(
  year: String,
  day: String,
  session: String,
) -> Result(String, String) {
  let url = "https://adventofcode.com/" <> year <> "/day/" <> day <> "/input"
  use request <- try(
    request.to(url)
    |> result.map_error(fn(error) {
      "Could not create request for \"" <> url <> "\": " <> string.inspect(
        error,
      )
    }),
  )

  // Send the HTTP request to the server
  use response <- try(
    request
    |> request.prepend_header("Accept", "application/json")
    |> request.prepend_header("Cookie", "session=" <> session <> ";")
    |> httpc.send
    |> result.map_error(fn(error) {
      "Error when requesting \"" <> url <> "\": " <> string.inspect(error)
    }),
  )

  case response.status {
    status if status >= 200 && status < 300 -> Ok(response.body)
    status -> Error(int.to_string(status) <> " - " <> response.body)
  }
}

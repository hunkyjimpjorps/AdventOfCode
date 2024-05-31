# httpc
<a href="https://github.com/gleam-lang/httpc/releases"><img src="https://img.shields.io/github/release/gleam-lang/httpc" alt="GitHub release"></a>
<a href="https://discord.gg/Fm8Pwmy"><img src="https://img.shields.io/discord/768594524158427167?color=blue" alt="Discord chat"></a>
![CI](https://github.com/gleam-lang/httpc/workflows/test/badge.svg?branch=main)

Bindings to Erlang's built in HTTP client, `httpc`.

```gleam
import gleam/httpc
import gleam/http.{Get}
import gleam/http/request
import gleam/http/response
import gleeunit/should

pub fn main() {
  // Prepare a HTTP request record
  let request = request.new()
    |> request.set_method(Get)
    |> request.set_host("test-api.service.hmrc.gov.uk")
    |> request.set_path("/hello/world")
    |> request.prepend_header("accept", "application/vnd.hmrc.1.0+json")

  // Send the HTTP request to the server
  try resp = httpc.send(req)

  // We get a response record back
  resp.status
  |> should.equal(200)

  resp
  |> response.get_header("content-type")
  |> should.equal(Ok("application/json"))

  resp.body
  |> should.equal("{\"message\":\"Hello World\"}")

  Ok(resp)
}
```

## Installation

```shell
gleam add gleam_httpc
```

## Use with Erlang/OTP versions older than 26.0

Older versions of HTTPC do not verify TLS connections by default, so with them
your connection may not be secure when using this library. Consider upgrading to
a newer version of Erlang/OTP, or using a different HTTP client such as
[hackney](https://github.com/gleam-lang/hackney).

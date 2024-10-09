import gleam/bit_array
import gleam/int
import gleam/io
import gleam/string
import gleam/string_builder.{type StringBuilder}
import simplifile

pub fn main() {
  let assert Ok(data) = simplifile.read(from: "./src/day3/data.txt")

  data
  |> string.split(" ")
  |> build_flat_image(" ", string_builder.new())
  |> bit_array.from_string()
  |> print_next_slice()
}

fn build_flat_image(
  nums: List(String),
  pixel: String,
  acc: StringBuilder,
) -> String {
  case nums {
    [] -> string_builder.to_string(acc)
    [h, ..t] -> {
      let assert Ok(n) = int.parse(h)
      let pixels = string.repeat(pixel, n)
      build_flat_image(t, next_pixel(pixel), string_builder.append(acc, pixels))
    }
  }
}

fn print_next_slice(str: BitArray) -> Nil {
  case str {
    <<slice:bytes-size(100), rest:bytes>> -> {
      let assert Ok(out) = bit_array.to_string(slice)
      io.println(out)
      print_next_slice(rest)
    }
    _ -> Nil
  }
}

fn next_pixel(p: String) -> String {
  case p {
    " " -> "#"
    "#" -> " "
    _ -> panic
  }
}

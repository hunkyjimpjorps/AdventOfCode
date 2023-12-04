import gleam/io
import gleam/bit_array

const str = "abcdefgh
abcdefgh"

pub fn main() {
  let trim = 8
  let <<_:bytes-size(trim), "\n":utf8, rest:bytes>> = bit_array.from_string(str)
  io.debug(rest)
}

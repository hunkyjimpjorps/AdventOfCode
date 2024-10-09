import gleam/dict
import gleam/io
import gleam/list
import gleam/regex
import gleam/result
import gleam/string
import simplifile

pub opaque type Location {
  Location(row: Int, col: Int)
}

pub fn main() {
  let assert Ok(data) = simplifile.read(from: "./src/day6/data.txt")
  let assert ["Cipher key: " <> key, "Message: " <> raw_message] =
    string.split(data, "\n")

  let letter_to_location = make_cipher_grid(key)
  let location_to_letter =
    letter_to_location
    |> dict.fold(dict.new(), fn(acc, k, v) { dict.insert(acc, v, k) })

  raw_message
  |> string.split(" ")
  |> list.map(fn(s) {
    s
    |> string.to_graphemes
    |> list.sized_chunk(2)
  })
  |> list.map(fn(s) {
    s
    |> decode_word(letter_to_location, location_to_letter)
    |> string.concat()
  })
  |> string.join(" ")
  |> io.println()
}

fn make_cipher_grid(key) {
  let assert Ok(in_key) = regex.from_string("[" <> key <> "]")
  let grid =
    regex.split(in_key, "abcdefghiklmnopqrstuvwxyz")
    |> string.concat
    |> string.append(key, _)
    |> string.to_graphemes
    |> list.sized_chunk(5)

  list.index_map(grid, fn(row, r) {
    list.index_map(row, fn(cell, c) { #(cell, Location(r, c)) })
  })
  |> list.flatten
  |> dict.from_list
}

fn decode_word(word: List(List(String)), to_loc, to_letter) {
  case word {
    [] -> []
    [[a, b], ..rest] -> [
      transform_pair(a, b, to_loc, to_letter),
      ..decode_word(rest, to_loc, to_letter)
    ]
    _ -> panic as "bad playfair format"
  }
}

fn transform_pair(a, b, to_loc, to_letter) {
  let assert Ok(Location(r_a, c_a)) = dict.get(to_loc, a)
  let assert Ok(Location(r_b, c_b)) = dict.get(to_loc, b)

  case r_a == r_b, c_a == c_b {
    True, _ -> [
      dict.get(to_letter, Location(r_a, { c_a + 4 } % 5)),
      dict.get(to_letter, Location(r_b, { c_b + 4 } % 5)),
    ]
    _, True -> [
      dict.get(to_letter, Location({ r_a + 4 } % 5, c_a)),
      dict.get(to_letter, Location({ r_b + 4 } % 5, c_b)),
    ]
    _, _ -> [
      dict.get(to_letter, Location(r_a, c_b)),
      dict.get(to_letter, Location(r_b, c_a)),
    ]
  }
  |> result.values
  |> string.concat
}

import gleam/int
import gleam/list
import gleam/option.{Some}
import gleam/order
import gleam/regexp.{Match}
import gleam/result
import gleam/string
import my_utils/to
import tote/bag

const a_codepoint = 97

const alphabet_len = 26

pub type Room {
  Room(name: String, id: Int, checksum: String)
}

pub fn parse(input: String) {
  input |> string.split("\n") |> list.map(parse_room)
}

fn parse_room(line: String) {
  let assert Ok(re) = regexp.from_string("([a-z\\-]*)-([0-9]*)\\[(.*)\\]")

  let assert [Match(submatches: [Some(name), Some(id), Some(checksum)], ..)] =
    regexp.scan(with: re, content: line)

  let id = to.int(id)

  Room(name:, id:, checksum:)
}

fn check_checksum(room: Room) {
  room.name
  |> string.to_graphemes
  |> bag.from_list()
  |> bag.remove_all("-")
  |> bag.to_list
  |> list.sort(sort_characters)
  |> list.take(5)
  |> list.map(fn(tup) { tup.0 })
  |> string.join("")
  |> fn(checksum) {
    case checksum == room.checksum {
      True -> Ok(room)
      False -> Error(Nil)
    }
  }
}

fn sort_characters(freq_a: #(String, Int), freq_b: #(String, Int)) {
  case int.compare(freq_b.1, freq_a.1) {
    order.Eq -> string.compare(freq_a.0, freq_b.0)
    other -> other
  }
}

pub fn pt_1(input: List(Room)) {
  list.fold(input, 0, fn(acc, room) {
    case check_checksum(room) {
      Ok(real_room) -> acc + real_room.id
      Error(..) -> acc
    }
  })
}

fn translate_room(room: Room) {
  Room(..room, name: shift_ahead(room.name, room.id))
}

fn shift_ahead(name, shift) {
  case string.pop_grapheme(name) {
    Error(..) -> ""
    Ok(#("-", rest)) -> " " <> shift_ahead(rest, shift)
    Ok(#(next, rest)) -> shift_grapheme(next, shift) <> shift_ahead(rest, shift)
  }
}

fn shift_grapheme(grapheme, shift) {
  let assert [c] = string.to_utf_codepoints(grapheme)

  let assert Ok(codepoint) =
    c
    |> string.utf_codepoint_to_int
    |> fn(n) { { n - a_codepoint + shift } % alphabet_len + a_codepoint }
    |> string.utf_codepoint
  string.from_utf_codepoints([codepoint])
}

pub fn pt_2(input: List(Room)) {
  let assert Ok(target_room) =
    list.find(input, fn(room) {
      room
      |> check_checksum()
      |> result.map(fn(room) {
        string.starts_with(translate_room(room).name, "northpole")
      })
      |> result.unwrap(False)
    })

  target_room.id
}

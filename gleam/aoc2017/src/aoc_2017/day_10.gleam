import gleam/int
import gleam/list
import gleam/result
import gleam/string

const size = 256

const suffix = [17, 31, 73, 47, 23]

fn parse_as_numbers(input: String) {
  input
  |> string.split(",")
  |> list.map(int.parse)
  |> result.values()
}

fn parse_as_bytes(input: String) {
  input
  |> string.to_utf_codepoints
  |> list.map(string.utf_codepoint_to_int)
  |> list.append(suffix)
}

pub fn pt_1(input: String) {
  let twisted = twist(list.range(0, size - 1), parse_as_numbers(input), 0, 0)

  let assert #([first, second, ..], _, _) = twisted
  first * second
}

pub fn pt_2(input: String) {
  megatwist(list.range(0, size - 1), parse_as_bytes(input), 0, 0, 64)
  |> list.sized_chunk(16)
  |> list.map(fold_xor)
  |> string.concat()
}

fn twist(loop: List(Int), lengths: List(Int), skip: Int, index: Int) {
  case lengths {
    [] -> #(loop, skip, index)
    [l, ..ls] ->
      loop
      |> roll(index)
      |> flip(l)
      |> roll({ size - index } % size)
      |> twist(ls, skip + 1, { index + l + skip } % size)
  }
}

fn megatwist(loop, lengths, skip, index, iterations) {
  case iterations {
    0 -> loop
    n -> {
      let #(next_loop, next_skip, next_index) =
        twist(loop, lengths, skip, index)
      megatwist(next_loop, lengths, next_skip, next_index, n - 1)
    }
  }
}

fn roll(list: List(a), by: Int) {
  let #(left, right) = list.split(list, by % size)
  list.append(right, left)
}

fn flip(list: List(a), length: Int) {
  let #(left, right) = list.split(list, length)
  list.append(list.reverse(left), right)
}

fn fold_xor(xs: List(Int)) {
  let assert Ok(n) = list.reduce(xs, int.bitwise_exclusive_or)
  n
  |> int.to_base16()
  |> string.pad_left(to: 2, with: "0")
  |> string.lowercase()
}

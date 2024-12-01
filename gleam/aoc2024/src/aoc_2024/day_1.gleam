import gleam/int
import gleam/list
import gleam/result
import gleam/string
import tote/bag

pub fn pt_1(input: String) {
  input
  |> string.split("\n")
  |> list.map(fn(str) { str |> string.split("   ") |> list.map(assert_int) })
  |> list.transpose()
  |> list.map(list.sort(_, int.compare))
  |> list.transpose()
  |> list.fold(0, fn(acc, ns) {
    let assert [a, b] = ns
    acc + int.absolute_value(a - b)
  })
}

pub fn pt_2(input: String) {
  let #(first, second) =
    input
    |> string.split("\n")
    |> list.map(string.split_once(_, "   "))
    |> result.values()
    |> list.unzip()

  let second = list.map(second, assert_int) |> bag.from_list

  use acc, raw_n <- list.fold(first, 0)
  let n = assert_int(raw_n)
  let freq = bag.copies(second, n)
  n * freq + acc
}

fn assert_int(str) {
  let assert Ok(n) = int.parse(str)
  n
}

import gleam/int
import gleam/list
import my_utils/to

pub fn parse(input: String) {
  use s <- to.delimited_list(input, "\n")
  case s {
    "R" <> n -> to.int(n)
    "L" <> n -> -to.int(n)
    _ -> panic
  }
}

pub fn pt_1(input: List(Int)) {
  input
  |> list.scan(50, int.add)
  |> list.count(fn(n) { n % 100 == 0 })
}

pub fn pt_2(input: List(Int)) {
  [0, ..input]
  |> list.scan(50, int.add)
  |> list.window_by_2
  |> list.fold(0, fn(acc, tup) {
    let assert [_, ..rest] = list.range(tup.0, tup.1)
    acc + list.count(rest, fn(n) { n % 100 == 0 })
  })
}

import gleam/int
import gleam/list
import gleam/string
import my_utils/to

pub fn parse(input: String) {
  string.split(input, "\n")
  |> list.map(fn(s) {
    case s {
      "R" <> n -> to.int(n)
      "L" <> n -> -to.int(n)
      _ -> panic
    }
  })
}

pub fn pt_1(input: List(Int)) {
  list.scan(input, 50, fn(acc, next) { acc + next })
  |> list.count(fn(n) { n % 100 == 0 })
}

pub fn pt_2(input: List(Int)) {
  list.scan([0, ..input], 50, fn(acc, next) { acc + next })
  |> list.window_by_2
  |> list.map(fn(tup) {
    let assert [_, ..rest] = list.range(tup.0, tup.1)
    list.count(rest, fn(n) { n % 100 == 0 })
  })
  |> int.sum()
}

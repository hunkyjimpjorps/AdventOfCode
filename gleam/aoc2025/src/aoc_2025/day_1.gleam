import gleam/int
import gleam/list
import gleam/pair
import my_utils/math
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
  |> list.scan(50, fn(acc, n) { math.mod(acc + n, 100) })
  |> list.count(fn(n) { n == 0 })
}

pub fn pt_2(input: List(Int)) {
  list.fold(input, #(50, 0), fn(acc, n) {
    let #(from, count) = acc
    let to = from + n
    let count = count + int.absolute_value(math.floor_div(to, 100))
    let adjustment = case n < 0, from {
      True, 0 if to % 100 != 0 -> -1
      True, _ if to % 100 == 0 -> 1
      _, _ -> 0
    }
    let pointer = math.mod(to, 100)
    #(pointer, count + adjustment)
  })
  |> pair.second
}

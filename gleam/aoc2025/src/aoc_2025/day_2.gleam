import gleam/int
import gleam/list
import gleam/set
import my_utils/math
import my_utils/to

pub fn parse(input: String) {
  use range <- to.delimited_list(input, ",")
  let assert [from, to] = to.delimited_list(range, "-", to.int)
  #(from, to)
}

fn repeat(n: Int, times: Int) {
  let shift = math.pow(10, math.length(n))
  do_repeat(n, times, shift, 0)
}

fn do_repeat(n: Int, times: Int, shift: Int, acc: Int) {
  case times {
    0 -> acc
    t -> do_repeat(n, t - 1, shift, n + acc * shift)
  }
}

fn is_in_range(n: Int, range: #(Int, Int)) {
  let #(lo, hi) = range
  lo <= n && n <= hi
}

pub fn pt_1(input: List(#(Int, Int))) {
  list.range(1, 99_999)
  |> list.map(repeat(_, 2))
  |> list.filter(fn(n) { list.any(input, is_in_range(n, _)) })
  |> int.sum
}

fn make_ids(spec: #(Int, Int)) {
  let #(length, repeats) = spec
  use n <- list.flat_map(list.range(
    math.pow(10, length - 1),
    math.pow(10, length) - 1,
  ))
  use r <- list.map(list.range(2, repeats))
  repeat(n, r)
}

pub fn pt_2(input: List(#(Int, Int))) {
  [#(1, 10), #(2, 5), #(3, 3), #(4, 2), #(5, 2)]
  |> list.fold(set.new(), fn(acc, next) {
    set.union(acc, make_ids(next) |> set.from_list)
  })
  |> set.fold(0, fn(acc, n) {
    case list.any(input, is_in_range(n, _)) {
      True -> acc + n
      False -> acc
    }
  })
}

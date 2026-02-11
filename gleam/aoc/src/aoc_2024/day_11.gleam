import gleam/float
import gleam/int
import gleam/list
import gleam/result
import gleam_community/maths
import my_utils/math
import my_utils/to
import rememo/memo

pub fn parse(input: String) {
  to.ints(input, " ")
}

fn blink(stone: Int, blinks: Int, cache) {
  use <- memo.memoize(cache, #(stone, blinks))
  case stone, digits(stone), blinks {
    _, _, 0 -> 1
    0, _, b -> blink(1, b - 1, cache)
    n, d, b if d % 2 == 0 -> {
      let #(l, r) = split(n, d)
      blink(l, b - 1, cache) + blink(r, b - 1, cache)
    }
    n, _, b -> blink(n * 2024, b - 1, cache)
  }
}

fn digits(n: Int) -> Int {
  n
  |> int.to_float
  |> maths.logarithm_10
  |> result.unwrap(0.0)
  |> float.add(1.0)
  |> float.floor
  |> float.truncate
}

fn split(stone: Int, digits: Int) -> #(Int, Int) {
  #(stone / math.pow(10, digits / 2), stone % math.pow(10, digits / 2))
}

fn blink_a_lot(input: List(Int), times: Int) -> Int {
  use cache <- memo.create()
  list.fold(input, 0, fn(acc, x) { acc + blink(x, times, cache) })
}

pub fn pt_1(input: List(Int)) -> Int {
  blink_a_lot(input, 25)
}

pub fn pt_2(input: List(Int)) -> Int {
  blink_a_lot(input, 75)
}

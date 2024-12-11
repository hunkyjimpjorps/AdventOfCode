import gleam/bool
import gleam/float
import gleam/int
import gleam/list
import gleam/result
import gleam_community/maths/elementary
import my_utils/math
import my_utils/to
import pocket_watch
import rememo/memo

pub fn parse(input: String) {
  to.ints(input, " ")
}

fn transform_stone(stone: Int, blinks: Int, cache) {
  use <- memo.memoize(cache, #(stone, blinks))
  use <- bool.guard(blinks == 0, 1)
  case stone, digits(stone) {
    0, _ -> transform_stone(1, blinks - 1, cache)
    n, d if d % 2 == 0 ->
      list.fold(split(n, d), 0, fn(acc, x) {
        acc + transform_stone(x, blinks - 1, cache)
      })
    n, _ -> transform_stone(n * 2024, blinks - 1, cache)
  }
}

fn digits(n: Int) -> Int {
  n
  |> int.to_float
  |> elementary.logarithm_10
  |> result.unwrap(0.0)
  |> float.add(1.0)
  |> float.floor
  |> float.truncate
}

fn split(stone: Int, digits: Int) -> List(Int) {
  [stone / math.pow(10, digits / 2), stone % math.pow(10, digits / 2)]
}

fn blink_a_lot(input: List(Int), times: Int) -> Int {
  use cache <- memo.create()
  list.fold(input, 0, fn(acc, x) { acc + transform_stone(x, times, cache) })
}

pub fn pt_1(input: List(Int)) -> Int {
  use <- pocket_watch.simple("Part 1")
  blink_a_lot(input, 25)
}

pub fn pt_2(input: List(Int)) -> Int {
  use <- pocket_watch.simple("Part 2")
  blink_a_lot(input, 75)
}

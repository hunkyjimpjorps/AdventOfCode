import gleam/io
import gleam/int
import gleam/list
import utilities/memo

const options = [40, 12, 2, 1]

const distance = 856

pub fn main() {
  use cache <- memo.create()
  solve(distance, cache)
  |> io.debug
}

fn solve(target, cache) {
  use <- memo.memoize(cache, target)
  case target {
    0 -> 1
    _ ->
      options
      |> list.filter(fn(n) { n <= target })
      |> list.map(fn(n) { solve(target - n, cache) })
      |> int.sum
  }
}

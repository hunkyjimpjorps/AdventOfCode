import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import my_utils/math
import my_utils/to

type Signal =
  #(Int, Int, Int, Int)

fn mix(value: Int, secret: Int) -> Int {
  int.bitwise_exclusive_or(value, secret)
}

fn prune(secret: Int) -> Int {
  let assert Ok(result) = int.modulo(secret, 16_777_216)
  result
}

fn evolve(secret: Int) -> Int {
  let step_1 = secret |> int.multiply(64) |> mix(secret) |> prune
  let step_2 = step_1 |> math.divide(32) |> mix(step_1) |> prune
  step_2 |> int.multiply(2048) |> mix(step_2) |> prune
}

pub fn parse(input: String) -> List(Int) {
  to.ints(input, "\n")
}

pub fn pt_1(input: List(Int)) -> Int {
  use sum, n <- list.fold(input, 0)
  sum + list.fold(list.range(1, 2000), n, fn(acc, _) { evolve(acc) })
}

fn generate_prices(number: Int, index: Int, acc: List(Int)) -> List(Int) {
  case index {
    0 -> list.reverse(acc)
    i -> generate_prices(evolve(number), i - 1, [number % 10, ..acc])
  }
}

fn calculate_deltas(price_list: List(Int)) -> List(Int) {
  price_list
  |> list.drop(2)
  |> list.window_by_2
  |> list.map(fn(tup) { tup.1 - tup.0 })
}

fn window_by_4(xs: List(Int), acc: List(Signal)) -> List(Signal) {
  case xs {
    [a, b, c, d] -> [#(a, b, c, d), ..acc] |> list.reverse
    [a, b, c, d, ..rest] ->
      window_by_4([b, c, d, ..rest], [#(a, b, c, d), ..acc])
    _ -> panic
  }
}

fn make_buyer_stats(initial: Int) -> Dict(Signal, Int) {
  let price_list = generate_prices(initial, 2000, [])
  let signals_list = calculate_deltas(price_list) |> window_by_4([])

  list.zip(signals_list, price_list |> list.drop(6))
  |> list.reverse
  |> dict.from_list
}

pub fn pt_2(input: List(Int)) -> Int {
  let best_price = {
    use acc, n <- list.fold(input, dict.new())
    use new_acc, code, price <- dict.fold(make_buyer_stats(n), acc)
    use existing <- dict.upsert(new_acc, code)
    case existing {
      None -> price
      Some(existing_price) -> existing_price + price
    }
  }

  use max, _, purchased <- dict.fold(best_price, 0)
  case purchased > max {
    True -> purchased
    False -> max
  }
}

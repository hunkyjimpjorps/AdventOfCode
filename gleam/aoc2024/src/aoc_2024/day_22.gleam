import gleam/dict
import gleam/int
import gleam/list
import gleam/option
import my_utils/math
import my_utils/to

fn mix(value, secret) {
  int.bitwise_exclusive_or(value, secret)
}

fn prune(secret) {
  let assert Ok(result) = int.modulo(secret, 16_777_216)
  result
}

fn evolve(secret) {
  let step_1 = secret |> int.multiply(64) |> mix(secret) |> prune
  let step_2 = step_1 |> math.divide(32) |> mix(step_1) |> prune
  step_2 |> int.multiply(2048) |> mix(step_2) |> prune
}

pub fn parse(input: String) {
  to.ints(input, "\n")
}

pub fn pt_1(input: List(Int)) {
  use sum, n <- list.fold(input, 0)
  sum + list.fold(list.range(1, 2000), n, fn(acc, _) { evolve(acc) })
}

fn generate_prices(number, index, acc) {
  case index {
    0 -> list.reverse(acc)
    i -> {
      let last_digit = number % 10
      generate_prices(evolve(number), i - 1, [last_digit, ..acc])
    }
  }
}

fn calculate_deltas(price_list) {
  price_list
  |> list.drop(2)
  |> list.window_by_2
  |> list.map(fn(tup) { tup.1 - tup.0 })
}

fn make_buyer_stats(initial) {
  let price_list = generate_prices(initial, 2000, [])
  let signals_list = calculate_deltas(price_list) |> list.window(4)
  let signals =
    list.map(signals_list, fn(xs) {
      let assert [a, b, c, d] = xs
      #(a, b, c, d)
    })

  list.zip(signals, price_list |> list.drop(6))
  |> list.reverse
  |> dict.from_list
}

pub fn pt_2(input: List(Int)) {
  let best_price = {
    use acc, n <- list.fold(input, dict.new())
    use new_acc, code, price <- dict.fold(make_buyer_stats(n), acc)
    use existing <- dict.upsert(new_acc, code)
    case existing {
      option.None -> price
      option.Some(existing_price) -> existing_price + price
    }
  }

  use max, _, purchased <- dict.fold(best_price, 0)
  case purchased > max {
    True -> purchased
    False -> max
  }
}

import gleam/int
import gleam/list
import gleam/order
import gleam/pair
import gleam/result
import gleam/string
import my_utils/to

fn decode(input, target) {
  input
  |> to.lists_of_graphemes
  |> list.transpose
  |> list.map(fn(col) {
    col
    |> to.frequencies
    |> list.reduce(fn(acc, pair) {
      case int.compare(pair.1, acc.1) {
        result if result == target -> pair
        _ -> acc
      }
    })
    |> result.map(pair.first)
  })
  |> result.values
  |> string.join("")
}

pub fn pt_1(input: String) {
  decode(input, order.Gt)
}

pub fn pt_2(input: String) {
  decode(input, order.Gt)
}

import gleam/dict
import gleam/int
import gleam/list
import gleam/order
import gleam/string

pub fn parse(input: String) -> List(List(String)) {
  input
  |> string.split("\n")
  |> list.map(string.to_graphemes)
  |> list.transpose()
}

fn roll_boulders(strs: List(String)) {
  use chunks <- list.flat_map(list.chunk(strs, fn(c) { c == "O" || c == "." }))
  list.sort(chunks, order.reverse(string.compare))
}

fn score(matrix) {
  use acc, col <- list.fold(matrix, 0)
  use col_acc, char, n <- list.index_fold(list.reverse(col), acc)
  case char {
    "O" -> col_acc + n + 1
    _ -> col_acc
  }
}

pub fn pt_1(input: List(List(String))) {
  input |> list.map(roll_boulders) |> score()
}

fn rotate(matrix) {
  matrix |> list.map(list.reverse) |> list.transpose
}

fn spin(matrix) {
  use acc, _ <- list.fold(list.range(1, 4), matrix)
  acc
  |> list.map(roll_boulders)
  |> rotate
}

fn check_if_seen(matrix, cache, count) {
  case dict.get(cache, matrix) {
    Error(Nil) ->
      check_if_seen(spin(matrix), dict.insert(cache, matrix, count), count - 1)
    Ok(n) -> {
      let assert Ok(extra) = int.modulo(count, n - count)
      list.fold(list.range(1, extra), matrix, fn(acc, _) { spin(acc) })
      |> score
    }
  }
}

pub fn pt_2(input: List(List(String))) {
  check_if_seen(input, dict.new(), 1_000_000_000)
}

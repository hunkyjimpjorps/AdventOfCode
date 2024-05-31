import adglent.{First, Second}
import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/order
import gleam/string

fn parse(input) {
  input
  |> string.split("\n")
  |> list.map(string.to_graphemes)
  |> list.transpose()
}

fn roll_boulders(strs: List(String)) {
  {
    use chunks <- list.map(list.chunk(strs, fn(c) { c == "O" || c == "." }))
    list.sort(chunks, order.reverse(string.compare))
  }
  |> list.flatten
}

fn score(matrix) {
  use acc, col <- list.fold(matrix, 0)
  acc
  + {
    use col_acc, char, n <- list.index_fold(list.reverse(col), 0)
    case char {
      "O" -> col_acc + n + 1
      _ -> col_acc
    }
  }
}

pub fn part1(input: String) {
  input
  |> parse
  |> list.map(roll_boulders)
  |> score()
  |> string.inspect
}

fn rotate(matrix) {
  matrix
  |> list.map(list.reverse)
  |> list.transpose
}

fn spin(matrix) {
  use acc, _ <- list.fold(list.range(1, 4), matrix)
  acc
  |> list.map(roll_boulders)
  |> rotate
}

fn spin_cycle(matrix) {
  let cache = dict.new()
  check_if_seen(matrix, cache, 1_000_000_000)
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

pub fn part2(input: String) {
  input
  |> parse
  |> spin_cycle
  |> string.inspect
}

pub fn main() {
  let assert Ok(part) = adglent.get_part()
  let assert Ok(input) = adglent.get_input("14")
  case part {
    First ->
      part1(input)
      |> adglent.inspect
      |> io.println
    Second ->
      part2(input)
      |> adglent.inspect
      |> io.println
  }
}

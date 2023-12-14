import adglent.{First, Second}
import gleam/io
import gleam/string
import gleam/list
import gleam/order
import gleam/int
import gleam/iterator
import gleam/result
import utilities/memo.{type Cache}

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

fn score(matrix, cache) {
  use <- memo.memoize(cache, matrix)
  {
    use col <- list.map(matrix)
    list.index_map(list.reverse(col), fn(i, c) { #(i + 1, c) })
    |> list.fold(
      0,
      fn(acc, tup) {
        case tup {
          #(n, "O") -> acc + n
          _ -> acc
        }
      },
    )
  }
  |> int.sum
}

pub fn part1(input: String) {
  use cache: Cache(List(List(String)), Int) <- memo.create()
  input
  |> parse
  |> list.map(roll_boulders)
  |> score(cache)
  |> string.inspect
}

fn rotate(matrix) {
  matrix
  |> list.map(list.reverse)
  |> list.transpose
}

fn spin_the_board(matrix, cache) {
  use <- memo.memoize(cache, matrix)
  matrix
  |> list.map(roll_boulders)
  |> rotate
}

pub fn part2(input: String) {
  use cache: Cache(List(List(String)), List(List(String))) <- memo.create()
  use score_cache: Cache(List(List(String)), Int) <- memo.create()
  input
  |> parse
  |> iterator.iterate(spin_the_board(_, cache))
  |> iterator.map(score(_, score_cache))
  |> iterator.at(10000)
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

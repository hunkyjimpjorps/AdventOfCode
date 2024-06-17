import aoc_2017/day_10.{pt_2 as knot}
import gleam/int
import gleam/list
import gleam/result
import gleam/set
import gleam/string
import helpers/set_state

pub fn pt_1(input: String) {
  use acc, row <- list.fold(make_rows(input), 0)
  let count = row |> knot() |> popcount()
  acc + count
}

fn make_rows(input: String) {
  use row <- list.map(list.range(0, 127))
  input <> "-" <> int.to_string(row)
}

fn popcount(hex_number: String) -> Int {
  let assert Ok(n) = int.base_parse(hex_number, 16)
  let assert Ok(digits) = int.digits(n, 2)

  use acc, digit <- list.fold(digits, 0)
  case digit {
    1 -> acc + 1
    _ -> acc
  }
}

pub fn pt_2(input: String) {
  let grid = set_state.start_actor(make_grid(input))

  find_next_group(grid, 0)
}

fn make_grid(input: String) {
  let raw_grid =
    list.map(make_rows(input), fn(row) {
      row
      |> knot()
      |> int.base_parse(16)
      |> result.map(int.to_base2)
      |> result.map(string.pad_left(_, with: "0", to: 128))
      |> result.map(string.to_graphemes)
    })
    |> result.values

  {
    use total_acc, row, i <- list.index_fold(raw_grid, set.new())
    use acc, bit, j <- list.index_fold(row, total_acc)
    case bit {
      "1" -> set.insert(acc, #(i, j))
      _zero -> acc
    }
  }
}

fn find_next_group(actor, count) {
  case set_state.pop(actor) {
    Ok(p) -> {
      list.each(neighbors(p), remove_neighbor(actor, _))
      find_next_group(actor, count + 1)
    }
    Error(Nil) -> count
  }
}

fn neighbors(of: #(Int, Int)) {
  let #(i, j) = of
  [#(i + 1, j), #(i - 1, j), #(i, j + 1), #(i, j - 1)]
}

fn remove_neighbor(actor, point) {
  case set_state.check(actor, point) {
    True -> {
      set_state.drop(actor, point)
      list.each(neighbors(point), remove_neighbor(actor, _))
    }
    False -> Nil
  }
}

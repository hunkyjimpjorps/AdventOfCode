import gleam/int
import gleam/list
import gleam/order
import gleam/string
import my_utils/math
import my_utils/to

type Parsed =
  List(Batteries)

type Batteries =
  List(Battery)

pub type Battery {
  Battery(joltage: Int, index: Int)
}

const pack_length = 100

pub fn parse(input: String) -> Parsed {
  use c <- to.delimited_list(input, "\n")
  c
  |> string.to_graphemes
  |> list.index_map(fn(c, i) { Battery(to.int(c), i) })
  |> list.sort(fn(left, right) {
    order.break_tie(
      in: int.compare(right.joltage, left.joltage),
      with: int.compare(left.index, right.index),
    )
  })
}

fn get_best_combo(
  batteries: List(Battery),
  remaining: Int,
  acc: List(Int),
) -> Int {
  case remaining {
    0 -> math.undigits(acc)
    _ -> {
      let assert Ok(Battery(joltage, index)) =
        list.find(batteries, fn(batt) { pack_length - batt.index >= remaining })
      let candidates = list.drop_while(batteries, fn(b) { b.index <= index })
      get_best_combo(candidates, remaining - 1, [joltage, ..acc])
    }
  }
}

pub fn pt_1(input: Parsed) -> Int {
  use acc, batteries <- list.fold(input, 0)
  acc + get_best_combo(batteries, 2, [])
}

pub fn pt_2(input: Parsed) -> Int {
  use acc, batteries <- list.fold(input, 0)
  acc + get_best_combo(batteries, 12, [])
}

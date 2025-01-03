import gleam/int
import gleam/list

pub fn parse(input: String) {
  let assert Ok(n) = int.parse(input)
  n
}

pub fn pt_1(input: Int) {
  let assert [_, result] =
    next_spin([0], 0, 1, input)
    |> list.drop_while(fn(x) { x != 2017 })
    |> list.take(2)

  result
}

fn next_spin(list: List(Int), position: Int, cycle: Int, step: Int) {
  case cycle {
    2018 -> list
    _ -> {
      let next_position = { position + step } % cycle + 1
      next_spin(
        insert_at(list, next_position, cycle),
        next_position,
        cycle + 1,
        step,
      )
    }
  }
}

fn insert_at(xs: List(a), at index: Int, insert new: a) {
  let #(left, right) = list.split(xs, index)
  list.flatten([left, [new], right])
}

pub fn pt_2(input: Int) {
  next_spin_tracking_zero(0, 0, 1, input)
}

fn next_spin_tracking_zero(acc: Int, position: Int, cycle: Int, step: Int) {
  case cycle {
    50_000_001 -> acc
    _ -> {
      let next_position = { position + step } % cycle + 1
      let next_acc = case next_position {
        1 -> cycle
        _ -> acc
      }
      next_spin_tracking_zero(next_acc, next_position, cycle + 1, step)
    }
  }
}

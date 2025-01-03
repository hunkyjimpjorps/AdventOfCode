import gleam/int
import gleam/list
import gleam/order
import gleam/string
import rememo/memo

pub type Point =
  #(Int, Int)

pub type NumericButton {
  Number(n: Int)
  Submit
}

pub type DirectionalButton {
  Up
  Down
  Left
  Right
  Push
}

fn num_to_coord(button: NumericButton) {
  case button {
    Number(7) -> #(0, 1)
    Number(8) -> #(0, 2)
    Number(9) -> #(0, 3)
    Number(4) -> #(1, 1)
    Number(5) -> #(1, 2)
    Number(6) -> #(1, 3)
    Number(1) -> #(2, 1)
    Number(2) -> #(2, 2)
    Number(3) -> #(2, 3)
    Number(0) -> #(3, 2)
    Submit -> #(3, 3)
    _ -> panic
  }
}

fn dir_to_coord(button: DirectionalButton) {
  case button {
    Up -> #(0, 2)
    Push -> #(0, 3)
    Left -> #(1, 1)
    Down -> #(1, 2)
    Right -> #(1, 3)
  }
}

fn make_move(a, b, lt, gt) {
  case int.compare(a, b) {
    order.Lt -> list.repeat(lt, b - a)
    order.Eq -> []
    order.Gt -> list.repeat(gt, a - b)
  }
}

// In general, the best button sequences will have all the moves lined up,
// like >>^^ and ^^>> but not >^>^, since repeated sequences require only one press,
// so there'll be one possible move if one of those would cause the robot arm
// to move through the gap, and two otherwise
fn to_next_numeric(pair: #(NumericButton, NumericButton)) {
  let #(#(ar, ac), #(br, bc)) as posns = #(
    num_to_coord(pair.0),
    num_to_coord(pair.1),
  )

  let move_rows = make_move(ar, br, Down, Up)
  let move_cols = make_move(ac, bc, Right, Left)

  case posns {
    _ if ar - br == 0 -> [list.append(move_cols, [Push])]
    _ if ac - bc == 0 -> [list.append(move_rows, [Push])]
    // If you start in the third row and move to the first column, 
    // that could pass you through the gap if you move left first
    #(#(3, _), #(_, 1)) -> [list.flatten([move_rows, move_cols, [Push]])]
    // Same idea with starting in the first column and moving to the third row
    #(#(_, 1), #(3, _)) -> [list.flatten([move_cols, move_rows, [Push]])]

    _ -> [
      list.flatten([move_rows, move_cols, [Push]]),
      list.flatten([move_cols, move_rows, [Push]]),
    ]
  }
}

fn numpad_directions(code: String) {
  string.to_graphemes("A" <> code)
  |> list.map(fn(chr) {
    case int.parse(chr) {
      Ok(n) -> Number(n)
      Error(_) -> Submit
    }
  })
  |> list.window_by_2
  |> list.map(to_next_numeric)
}

fn to_next_direction(pair: #(DirectionalButton, DirectionalButton)) {
  let #(#(ar, ac), #(br, bc)) as posns = #(
    dir_to_coord(pair.0),
    dir_to_coord(pair.1),
  )

  let move_rows = make_move(ar, br, Down, Up)
  let move_cols = make_move(ac, bc, Right, Left)

  case posns {
    _ if ar - br == 0 -> [list.append(move_cols, [Push])]
    _ if ac - bc == 0 -> [list.append(move_rows, [Push])]
    #(#(1, 1), #(0, _)) -> [list.flatten([move_cols, move_rows, [Push]])]
    #(#(0, _), #(1, 1)) -> [list.flatten([move_rows, move_cols, [Push]])]
    _ -> [
      list.flatten([move_rows, move_cols, [Push]]),
      list.flatten([move_cols, move_rows, [Push]]),
    ]
  }
}

fn direction_directions(code: List(DirectionalButton)) {
  [Push, ..code]
  |> list.window_by_2
  |> list.map(to_next_direction)
}

fn count_presses(move, remaining, cache) {
  use <- memo.memoize(cache, #(move, remaining))
  let count_subsequent = fn(x) {
    list.fold(direction_directions(x), 0, fn(acc, move) {
      acc + count_presses(move, remaining - 1, cache)
    })
  }
  case remaining, move {
    0, [last] -> list.length(last)
    0, [last_a, last_b] -> int.min(list.length(last_a), list.length(last_b))
    _, [one] -> count_subsequent(one)
    _, [a, b] -> int.min(count_subsequent(a), count_subsequent(b))
    _, _ -> panic
  }
}

fn get_numeric_part(code: String) {
  let assert Ok(n) = code |> string.drop_end(1) |> int.parse
  n
}

fn daisy_chain(input, times) {
  use cache <- memo.create()
  use total, code <- list.fold(input, 0)
  use acc, move <- list.fold(numpad_directions(code), total)
  acc + count_presses(move, times, cache) * get_numeric_part(code)
}

pub fn parse(input: String) {
  input |> string.split("\n")
}

pub fn pt_1(input: List(String)) {
  daisy_chain(input, 2)
}

pub fn pt_2(input: List(String)) {
  daisy_chain(input, 25)
}

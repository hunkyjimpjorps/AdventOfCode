import gleam/list
import gleam/order.{type Order, Gt, Lt}
import gleam/set.{type Set}
import gleam/string
import my_utils/from

pub type Update =
  List(Int)

pub type Pairs =
  Set(List(Int))

pub type Input {
  Input(updates: List(Update), pairs: Pairs)
}

pub fn parse(input: String) -> Input {
  let assert Ok(#(rules, raw_updates)) = string.split_once(input, "\n\n")

  let pairs = rules |> from.list_of_list_of_ints("|") |> set.from_list
  let updates = from.list_of_list_of_ints(raw_updates, ",")

  Input(updates, pairs)
}

fn page_order(first: Int, second: Int, pairs: Pairs) -> Order {
  case set.contains(pairs, [first, second]) {
    True -> Lt
    False -> Gt
  }
}

fn middle_of_list(xs: List(a)) -> a {
  let assert Ok(result) = do_middle(xs, xs)
  result
}

fn do_middle(one_step: List(a), two_step: List(a)) -> Result(a, Nil) {
  case one_step, two_step {
    [middle, ..], [] | [middle, ..], [_] -> Ok(middle)
    [_, ..one_rest], [_, _, ..two_rest] -> do_middle(one_rest, two_rest)
    _, _ -> Error(Nil)
  }
}

pub fn pt_1(input: Input) -> Int {
  let Input(updates, pairs) = input

  use acc, update <- list.fold(updates, 0)
  case update, list.sort(update, fn(a, b) { page_order(a, b, pairs) }) {
    before, after if before == after -> acc + middle_of_list(update)
    _, _ -> acc
  }
}

pub fn pt_2(input: Input) {
  let Input(updates, pairs) = input

  use acc, update <- list.fold(updates, 0)
  case update, list.sort(update, fn(a, b) { page_order(a, b, pairs) }) {
    before, after if before == after -> acc
    _, after -> acc + middle_of_list(after)
  }
}

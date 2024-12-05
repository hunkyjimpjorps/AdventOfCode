import gleam/int
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

  let pairs =
    rules
    |> from.list_of_list_of_ints("|")
    |> set.from_list

  let updates = from.list_of_list_of_ints(raw_updates, ",")

  Input(updates, pairs)
}

fn page_order(first: Int, second: Int, pairs: Pairs) -> Order {
  case set.contains(pairs, [first, second]) {
    True -> Lt
    False -> Gt
  }
}

fn is_in_order(update: Update, pairs: Pairs) -> Bool {
  let sorted = list.sort(update, fn(a, b) { page_order(a, b, pairs) })
  update == sorted
}

fn middle_of_list(xs: List(a)) -> a {
  let len = list.length(xs)
  let assert [x, ..] = list.drop(xs, { len - 1 } / 2)
  x
}

pub fn pt_1(input: Input) -> Int {
  let Input(updates, pairs) = input
  list.filter(updates, is_in_order(_, pairs))
  |> list.map(middle_of_list)
  |> int.sum()
}

pub fn pt_2(input: Input) {
  let Input(updates, pairs) = input
  use acc, o <- list.fold(updates, 0)
  case is_in_order(o, pairs) {
    True -> acc
    False ->
      o
      |> list.sort(fn(a, b) { page_order(a, b, pairs) })
      |> middle_of_list
      |> int.add(acc)
  }
}

import gleam/list
import my_utils/from

pub fn parse(input: String) -> List(List(Int)) {
  from.list_of_list_of_ints(input, " ")
}

pub fn pt_1(input: List(List(Int))) -> Int {
  list.count(input, is_safe)
}

pub fn pt_2(input: List(List(Int))) -> Int {
  list.count(input, is_safe_at_any_speed)
}

fn is_safe(ns: List(Int)) -> Bool {
  let diffs =
    ns
    |> list.window_by_2
    |> list.map(fn(pair) { pair.1 - pair.0 })

  list.all(diffs, fn(n) { n >= 1 && n <= 3 })
  || list.all(diffs, fn(n) { n >= -3 && n <= -1 })
}

fn all_dampenings(ns: List(Int)) -> List(List(Int)) {
  let indexed = list.index_map(ns, fn(x, i) { #(i, x) })

  // if it's safe to begin with, then it'll also be safe if the first or last is removed
  // so it's not necessary to check the full list too, just the dampened ones
  use to_remove <- list.map(list.range(0, list.length(ns) - 1))
  use pair <- list.filter_map(indexed)
  case pair.0 {
    index if index == to_remove -> Error(Nil)
    _ -> Ok(pair.1)
  }
}

fn is_safe_at_any_speed(ns: List(Int)) -> Bool {
  ns |> all_dampenings |> list.any(is_safe)
}

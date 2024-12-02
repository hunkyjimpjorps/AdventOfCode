import gleam/bool
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

fn is_safe_at_any_speed(ns: List(Int)) -> Bool {
  use <- bool.guard(is_safe(ns), True)
  let indexed = list.index_map(ns, fn(x, i) { #(i, x) })
  use n <- list.any(list.range(0, list.length(ns) - 1))
  let assert Ok(#(_, remaining)) = list.key_pop(indexed, n)
  remaining |> list.map(fn(pair) { pair.1 }) |> is_safe
}

import gleam/int
import gleam/list
import gleam/result
import gleam/string
import rememo/memo

fn parse_folds(input: String, folds: Int) {
  let records = string.split(input, "\n")
  use record <- list.map(records)
  let assert Ok(#(template, sets_str)) = string.split_once(record, " ")

  let template =
    template
    |> list.repeat(folds)
    |> list.intersperse("?")
    |> string.concat
  let sets =
    sets_str
    |> string.split(",")
    |> list.map(int.parse)
    |> result.values
    |> list.repeat(folds)
    |> list.flatten()

  #(template, sets)
}

fn do_count(
  template: String,
  groups: List(Int),
  left: Int,
  gap: Bool,
  cache,
) -> Int {
  use <- memo.memoize(cache, #(template, groups, left, gap))
  case template, groups, left, gap {
    "", [], 0, _ -> 1
    "?" <> t_rest, [g, ..g_rest], 0, False ->
      do_count(t_rest, g_rest, g - 1, g == 1, cache)
      + do_count(t_rest, groups, 0, False, cache)
    "?" <> t_rest, [], 0, False
    | "?" <> t_rest, _, 0, True
    | "." <> t_rest, _, 0, _
    -> do_count(t_rest, groups, 0, False, cache)
    "#" <> t_rest, [g, ..g_rest], 0, False ->
      do_count(t_rest, g_rest, g - 1, g == 1, cache)
    "?" <> t_rest, gs, l, False | "#" <> t_rest, gs, l, False ->
      do_count(t_rest, gs, l - 1, l == 1, cache)
    _, _, _, _ -> 0
  }
}

fn count_solutions(acc: Int, condition: #(String, List(Int))) -> Int {
  use cache <- memo.create()
  let #(template, groups) = condition
  acc + do_count(template, groups, 0, False, cache)
}

pub fn pt_1(input: String) {
  input
  |> parse_folds(1)
  |> list.fold(0, count_solutions)
}

pub fn pt_2(input: String) {
  input
  |> parse_folds(5)
  |> list.fold(0, count_solutions)
}

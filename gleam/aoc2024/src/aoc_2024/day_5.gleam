import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/set.{type Set}
import gleam/string
import my_utils/from

pub fn parse(
  input: String,
) -> #(Dict(Int, Set(Int)), List(List(Int)), Set(#(Int, Int))) {
  let assert Ok(#(rules, orders)) = string.split_once(input, "\n\n")

  let pairs =
    rules
    |> from.list_of_list_of_ints("|")
    |> list.map(fn(xs) {
      let assert [a, b] = xs
      #(a, b)
    })
    |> set.from_list

  let rules =
    rules
    |> from.list_of_list_of_ints("|")
    |> list.fold(dict.new(), fn(acc, xs) {
      let assert [before, after] = xs
      dict.upsert(acc, after, fn(v) {
        case v {
          Some(vs) -> set.insert(vs, before)
          None -> set.new() |> set.insert(before)
        }
      })
    })

  let orders = from.list_of_list_of_ints(orders, ",")

  #(rules, orders, pairs)
}

fn is_in_order(update: List(Int), rules: Dict(Int, Set(Int))) {
  case update {
    [] -> True
    [first, ..rest] -> {
      case dict.get(rules, first) {
        Ok(must_be_before) -> {
          let is_after = set.from_list(rest)
          case set.is_disjoint(must_be_before, is_after) {
            True -> is_in_order(rest, rules)
            False -> False
          }
        }
        Error(_) -> is_in_order(rest, rules)
      }
    }
  }
}

fn middle_of_list(xs: List(a)) -> a {
  let len = list.length(xs)
  let assert [x, ..] = list.drop(xs, { len - 1 } / 2)
  x
}

pub fn pt_1(input: #(Dict(Int, Set(Int)), List(List(Int)), Set(#(Int, Int)))) {
  let #(rules, orders, _) = input
  list.filter(orders, is_in_order(_, rules))
  |> list.map(middle_of_list)
  |> int.sum()
}

fn sort_with_rules(
  update: List(Int),
  pairs: Set(#(Int, Int)),
  acc: List(Int),
  original: List(Int),
) {
  case update {
    [] ->
      case list.reverse(acc) == original {
        True -> original
        False ->
          sort_with_rules(list.reverse(acc), pairs, [], list.reverse(acc))
      }
    [only] -> sort_with_rules([], pairs, [only, ..acc], original)
    [first, second, ..rest] -> {
      case set.contains(pairs, #(first, second)) {
        True ->
          sort_with_rules([second, ..rest], pairs, [first, ..acc], original)
        False ->
          sort_with_rules([first, ..rest], pairs, [second, ..acc], original)
      }
    }
  }
}

pub fn pt_2(input: #(Dict(Int, Set(Int)), List(List(Int)), Set(#(Int, Int)))) {
  let #(rules, orders, pairs) = input
  list.filter(orders, fn(o) { !is_in_order(o, rules) })
  |> list.map(fn(o) { sort_with_rules(o, pairs, [], o) |> middle_of_list })
  |> int.sum
}

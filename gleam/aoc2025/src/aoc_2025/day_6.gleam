import gleam/int
import gleam/list
import gleam/regexp
import gleam/string
import my_utils/to

pub fn pt_1(input: String) {
  let assert Ok(re) = regexp.from_string("\\s+")
  input
  |> string.split("\n")
  |> list.reverse
  |> list.map(fn(str) { str |> string.trim |> regexp.split(re, _) })
  |> list.transpose
  |> list.fold(0, add_column_results)
}

fn add_column_results(acc, strs) {
  let assert [op, ..xs] = strs
  let xs = list.map(xs, to.int)
  case op {
    "*" -> acc + int.product(xs)
    "+" -> acc + int.sum(xs)
    _ -> panic
  }
}

pub fn pt_2(input: String) {
  input
  |> to.lists_of_graphemes
  |> list.transpose()
  |> list.map(parse_ops)
  |> do_math(0, int.sum, [])
}

fn parse_ops(col) {
  col
  |> list.filter(fn(ch) { ch != " " })
  |> list.partition(fn(ch) { ch == "*" || ch == "+" })
}

fn do_math(ops, acc, current_op, register) {
  case ops {
    [] -> acc + current_op(register)
    [#([], []), ..rest] ->
      do_math(rest, acc + current_op(register), current_op, [])
    [#(["+"], xs), ..rest] -> do_math(rest, acc, int.sum, [make_int(xs)])
    [#(["*"], xs), ..rest] -> do_math(rest, acc, int.product, [make_int(xs)])
    [#([], xs), ..rest] ->
      do_math(rest, acc, current_op, [make_int(xs), ..register])
    _ -> panic
  }
}

fn make_int(chs) {
  chs |> string.join("") |> to.int
}

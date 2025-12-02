import gleam/int
import gleam/list
import gleam/regexp
import my_utils/to

pub fn parse(input: String) {
  use range <- to.delimited_list(input, ",")
  let assert [from, to] = to.delimited_list(range, "-", to.int)
  #(from, to)
}

pub fn pt_1(input: List(#(Int, Int))) {
  let assert Ok(re) = regexp.from_string("^(\\d+)\\1$")
  sum_of_nonsense(input, re)
}

pub fn pt_2(input: List(#(Int, Int))) {
  let assert Ok(re) = regexp.from_string("^(\\d+)\\1+$")
  sum_of_nonsense(input, re)
}

fn sum_of_nonsense(input, re) {
  use outer_acc, tup <- list.fold(input, 0)
  let #(from, to) = tup
  use inner_acc, n <- list.fold(list.range(from, to), outer_acc)
  case is_nonsense(n, re) {
    True -> inner_acc + n
    False -> inner_acc
  }
}

fn is_nonsense(n: Int, re: regexp.Regexp) {
  regexp.check(re, int.to_string(n))
}

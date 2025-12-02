import gleam/int
import gleam/list
import gleam/regexp
import gleam/result
import my_utils/to
import parallel_map

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
  input
  |> parallel_map.list_pmap(
    fn(tup) {
      let #(from, to) = tup
      use acc, n <- list.fold(list.range(from, to), 0)
      case is_nonsense(n, re) {
        True -> acc + n
        False -> acc
      }
    },
    parallel_map.MatchSchedulersOnline,
    1000,
  )
  |> result.values
  |> int.sum
}

fn is_nonsense(n: Int, re: regexp.Regexp) {
  regexp.check(re, int.to_string(n))
}

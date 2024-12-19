import gleam/bool
import gleam/list
import gleam/string
import rememo/memo

pub fn parse(input: String) {
  let assert Ok(#(towels, targets)) = string.split_once(input, "\n\n")
  let towels = towels |> string.split(", ")
  let targets = targets |> string.split("\n")
  #(towels, targets)
}

fn count_pattern(remaining: String, prefixes: List(String), cache) {
  use <- memo.memoize(cache, remaining)
  use <- bool.guard(string.is_empty(remaining), 1)
  let ok_prefixes = list.filter(prefixes, string.starts_with(remaining, _))
  use acc, prefix <- list.fold(ok_prefixes, 0)
  let trimmed = prefix |> string.length |> string.drop_start(remaining, _)
  acc + count_pattern(trimmed, prefixes, cache)
}

pub fn pt_1(input: #(List(String), List(String))) {
  let #(towels, targets) = input
  use cache <- memo.create()
  use target <- list.count(targets)
  count_pattern(target, towels, cache) != 0
}

pub fn pt_2(input: #(List(String), List(String))) {
  let #(towels, targets) = input
  use cache <- memo.create()
  use acc, target <- list.fold(targets, 0)
  acc + count_pattern(target, towels, cache)
}

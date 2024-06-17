import gleam/dict
import gleam/list
import gleam/set.{type Set}
import gleam/string

type Pipes =
  dict.Dict(String, List(String))

pub fn parse(input: String) -> Pipes {
  use acc, row <- list.fold(string.split(input, "\n"), dict.new())
  let assert Ok(#(from, to)) = string.split_once(row, " <-> ")
  let to_nodes = string.split(to, ", ")
  dict.insert(acc, from, to_nodes)
}

pub fn pt_1(input: Pipes) {
  next_nodes("0", input, set.new()) |> set.size()
}

pub fn pt_2(input: Pipes) {
  count_groups(dict.keys(input), input, 0)
}

fn next_nodes(current: String, pipes: Pipes, found: Set(String)) {
  let assert Ok(to_nodes) = dict.get(pipes, current)

  use acc, node <- list.fold(to_nodes, found)
  case set.contains(found, node) {
    False -> acc |> set.insert(node) |> next_nodes(node, pipes, _)
    True -> acc
  }
}

fn count_groups(all_nodes: List(String), pipes: Pipes, count: Int) {
  case all_nodes {
    [] -> count
    [first, ..] -> {
      let next_subgraph = next_nodes(first, pipes, set.new())
      let remaining =
        list.filter(all_nodes, fn(n) { !set.contains(next_subgraph, n) })
      count_groups(remaining, pipes, count + 1)
    }
  }
}

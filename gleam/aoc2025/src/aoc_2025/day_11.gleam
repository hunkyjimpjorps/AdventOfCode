import aonyx/graph.{type Graph}
import aonyx/graph/edge
import aonyx/graph/node.{type Node}
import gleam/list
import gleam/set
import gleam/string
import rememo/memo

pub fn parse(input: String) -> Graph(String, a, b) {
  use outer_acc, line <- list.fold(string.split(input, "\n"), graph.new())
  let assert Ok(#(from, tos)) = string.split_once(line, ": ")
  let tos = string.split(tos, " ")
  use inner_acc, to <- list.fold(tos, outer_acc)
  graph.insert_edge(inner_acc, edge.new(from, to))
}

fn do_count_paths(
  from source: Node(a, b),
  to destination: Node(a, b),
  initial_length count: Int,
  over graph: Graph(a, b, c),
  with_cache cache,
) -> Int {
  use <- memo.memoize(cache, #(source, destination))
  case source == destination {
    True -> 1
    False -> {
      let neighbors_out = node.get_neighbors_out(source)
      use acc, neighbor <- set.fold(neighbors_out, count)
      let assert Ok(neighbor) = graph.get_node(graph, neighbor)
      do_count_paths(neighbor, destination, count, graph, cache) + acc
    }
  }
}

fn count_paths(
  from source: a,
  to destination: a,
  over graph: Graph(a, b, c),
) -> Int {
  let assert Ok(source) = graph.get_node(graph, source)
  let assert Ok(destination) = graph.get_node(graph, destination)

  use cache <- memo.create()
  do_count_paths(
    from: source,
    to: destination,
    initial_length: 0,
    over: graph,
    with_cache: cache,
  )
}

pub fn pt_1(input: Graph(String, a, b)) {
  count_paths(from: "you", to: "out", over: input)
}

pub fn pt_2(input: Graph(String, a, b)) {
  count_paths(from: "svr", to: "fft", over: input)
  * count_paths(from: "fft", to: "dac", over: input)
  * count_paths(from: "dac", to: "out", over: input)
}

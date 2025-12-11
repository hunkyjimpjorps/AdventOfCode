import gleam/dict.{type Dict}
import gleam/erlang/atom.{type Atom}
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/string
import rememo/memo

pub fn parse(input: String) -> Dict(Atom, List(Atom)) {
  use outer_acc, line <- list.fold(string.split(input, "\n"), dict.new())
  let assert Ok(#(from, tos)) = string.split_once(line, ": ")
  let tos = string.split(tos, " ")
  use inner_acc, to <- list.fold(tos, outer_acc)
  use v <- dict.upsert(inner_acc, atom.create(from))
  case v {
    Some(atoms) -> [atom.create(to), ..atoms]
    None -> [atom.create(to)]
  }
}

fn do_count_paths(
  from source: Atom,
  to destination: Atom,
  initial_length count: Int,
  over graph: Dict(Atom, List(Atom)),
  with_cache cache,
) -> Int {
  use <- memo.memoize(cache, source)
  case source == destination {
    True -> 1
    False -> {
      let neighbors_out = graph |> dict.get(source) |> result.unwrap([])
      use acc, neighbor <- list.fold(neighbors_out, count)
      do_count_paths(neighbor, destination, count, graph, cache) + acc
    }
  }
}

fn count_paths(
  from source: Atom,
  to destination: Atom,
  over graph: Dict(Atom, List(Atom)),
) -> Int {
  use cache <- memo.create()
  do_count_paths(
    from: source,
    to: destination,
    initial_length: 0,
    over: graph,
    with_cache: cache,
  )
}

pub fn pt_1(input: Dict(Atom, List(Atom))) {
  let assert [you, out] = ["you", "out"] |> list.map(atom.get) |> result.values

  count_paths(from: you, to: out, over: input)
}

pub fn pt_2(input: Dict(Atom, List(Atom))) {
  let assert [svr, fft, dac, out] =
    ["svr", "fft", "dac", "out"] |> list.map(atom.get) |> result.values

  count_paths(from: svr, to: fft, over: input)
  * count_paths(from: fft, to: dac, over: input)
  * count_paths(from: dac, to: out, over: input)
}

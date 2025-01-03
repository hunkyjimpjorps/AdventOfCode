import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/string

fn assert_int(str: String) {
  let assert Ok(n) = int.parse(str)
  n
}

fn parse_routes(lines: List(String), routes: Dict(#(String, String), Int)) {
  case lines {
    [] -> routes
    [line, ..rest] -> {
      let assert [from, "to", to, "=", raw_dist] = string.split(line, " ")
      let dist = assert_int(raw_dist)
      routes
      |> dict.insert(#(from, to), dist)
      |> dict.insert(#(to, from), dist)
      |> parse_routes(rest, _)
    }
  }
}

fn trace_route(cities: List(String), routes: Dict(#(String, String), Int)) {
  cities
  |> list.window_by_2
  |> list.fold(from: 0, with: fn(dist, leg) {
    let assert Ok(leg_dist) = dict.get(routes, leg)
    dist + leg_dist
  })
}

fn find_route_satisfying(input: String, using: fn(Int, Int) -> Int) {
  let routes = input |> string.split("\n") |> parse_routes(dict.new())
  let cities = routes |> dict.keys |> list.map(fn(tup) { tup.0 }) |> list.unique

  cities
  |> list.permutations
  |> list.map(trace_route(_, routes))
  |> list.reduce(using)
}

pub fn pt_1(input: String) {
  find_route_satisfying(input, int.min)
}

pub fn pt_2(input: String) {
  find_route_satisfying(input, int.max)
}

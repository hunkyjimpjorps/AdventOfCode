import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/set.{type Set}
import gleam/string
import my_utils/coord.{type Coord, Coord}
import my_utils/from

type Path {
  Unknown
  Straight
  Junction
}

type Route {
  Route(to: Coord, distance: Int)
}

fn append_to_key(v: Option(List(a)), new: a) -> List(a) {
  case v {
    None -> [new]
    Some(xs) -> [new, ..xs]
  }
}

fn first_parse_path(c: String) -> Result(Path, Nil) {
  case c {
    "#" -> Error(Nil)
    _ -> Ok(Unknown)
  }
}

fn junction_neighbors(p: Coord) -> List(Coord) {
  [Coord(..p, r: p.r + 1), Coord(..p, c: p.c + 1)]
}

fn mark_junctions(trails: Dict(Coord, Path)) -> Dict(Coord, Path) {
  use trail, _ <- dict.map_values(trails)

  let valid_neighbors =
    trail
    |> coord.neighbors(coord.cardinal_directions)
    |> list.filter(dict.has_key(trails, _))

  case list.length(valid_neighbors) {
    2 -> Straight
    _ -> Junction
  }
}

fn start_walking_to_next_junction(
  start: Coord,
  next: Coord,
  trails: Dict(Coord, Path),
) {
  let seen =
    set.new()
    |> set.insert(start)
    |> set.insert(next)
  walk_to_next_junction(start, next, 1, seen, trails)
}

fn walk_to_next_junction(
  start: Coord,
  current: Coord,
  length: Int,
  seen: Set(Coord),
  trails: Dict(Coord, Path),
) -> #(Coord, Route) {
  let assert [next] =
    current
    |> coord.neighbors(coord.cardinal_directions)
    |> list.filter(fn(n) { dict.has_key(trails, n) && !set.contains(seen, n) })

  case dict.get(trails, next) {
    Ok(Junction) -> #(start, Route(to: next, distance: length + 1))
    _ -> {
      let seen = set.insert(seen, current)
      walk_to_next_junction(start, next, { length + 1 }, seen, trails)
    }
  }
}

fn find_routes(junctions, trails) {
  use junction <- list.flat_map(junctions)
  use neighbor <- list.filter_map(junction_neighbors(junction))
  case dict.has_key(trails, neighbor) {
    True -> Ok(start_walking_to_next_junction(junction, neighbor, trails))
    False -> Error(Nil)
  }
}

fn generate_routes(
  junctions: List(Coord),
  trails: Dict(Coord, Path),
) -> Dict(Coord, List(Route)) {
  use acc, #(from, route) <- list.fold(
    find_routes(junctions, trails),
    dict.new(),
  )
  dict.upsert(acc, from, append_to_key(_, route))
}

fn generate_2way_routes(
  junctions: List(Coord),
  trails: Dict(Coord, Path),
) -> Dict(Coord, List(Route)) {
  use acc, #(from, route) <- list.fold(
    find_routes(junctions, trails),
    dict.new(),
  )
  acc
  |> dict.upsert(from, append_to_key(_, route))
  |> dict.upsert(route.to, append_to_key(_, Route(from, route.distance)))
}

fn dfs(routes, from, to) {
  let seen = set.insert(set.new(), from)
  do_dfs(routes, from, to, 0, seen)
}

fn do_dfs(
  routes: Dict(Coord, List(Route)),
  from: Coord,
  to: Coord,
  acc: Int,
  seen: Set(Coord),
) -> Int {
  use <- bool.guard(to == from, acc)

  let assert Ok(all_routes) = dict.get(routes, from)
  let neighbors = list.filter(all_routes, fn(r) { !set.contains(seen, r.to) })

  case neighbors {
    [] -> 0
    neighbors ->
      list.fold(neighbors, acc, fn(inner_acc, n) {
        let score =
          do_dfs(routes, n.to, to, acc + n.distance, set.insert(seen, n.to))
        int.max(score, inner_acc)
      })
  }
}

fn solve_using(
  input: String,
  using: fn(List(Coord), Dict(Coord, Path)) -> Dict(Coord, List(Route)),
) -> Int {
  let min_row = 0
  let max_row = list.length(string.split(input, "\n")) - 1

  let trails =
    from.try_grid(input, Coord, first_parse_path(_))
    |> mark_junctions

  let junctions =
    trails
    |> dict.filter(fn(_, v) { v == Junction })
    |> dict.keys

  let assert Ok(start) = list.find(junctions, fn(j) { j.r == min_row })
  let assert Ok(end) = list.find(junctions, fn(j) { j.r == max_row })

  let routes = using(junctions, trails)

  dfs(routes, start, end)
}

pub fn pt_1(input: String) {
  solve_using(input, generate_routes)
}

pub fn pt_2(input: String) {
  solve_using(input, generate_2way_routes)
}

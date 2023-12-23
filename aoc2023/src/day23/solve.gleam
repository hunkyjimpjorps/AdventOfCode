import adglent.{First, Second}
import gleam/int
import gleam/io
import gleam/dict.{type Dict}
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import gleam/set.{type Set}
import gleam/bool
import utilities/array2d.{type Array2D, type Posn, Posn}

type Path {
  Unknown
  Straight
  Junction
}

type Route {
  Route(to: Posn, distance: Int)
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

fn junction_neighbors(p: Posn) -> List(Posn) {
  [Posn(..p, r: p.r + 1), Posn(..p, c: p.c + 1)]
}

fn mark_junctions(trails: Array2D(Path)) -> Array2D(Path) {
  use trail, _ <- dict.map_values(trails)

  let valid_neighbors =
    trail
    |> array2d.ortho_neighbors
    |> list.filter(dict.has_key(trails, _))

  case list.length(valid_neighbors) {
    2 -> Straight
    _ -> Junction
  }
}

fn start_walking_to_next_junction(
  start: Posn,
  next: Posn,
  trails: Array2D(Path),
) {
  let seen =
    set.new()
    |> set.insert(start)
    |> set.insert(next)
  walk_to_next_junction(start, next, 1, seen, trails)
}

fn walk_to_next_junction(
  start: Posn,
  current: Posn,
  length: Int,
  seen: Set(Posn),
  trails: Array2D(Path),
) -> #(Posn, Route) {
  let assert [next] =
    current
    |> array2d.ortho_neighbors
    |> list.filter(fn(n) { dict.has_key(trails, n) && !set.contains(seen, n) })

  case dict.get(trails, next) {
    Ok(Junction) -> #(start, Route(to: next, distance: length + 1))
    _ -> {
      let seen = set.insert(seen, current)
      walk_to_next_junction(start, next, { length + 1 }, seen, trails)
    }
  }
}

fn generate_routes(
  junctions: List(Posn),
  trails: Array2D(Path),
) -> Dict(Posn, List(Route)) {
  {
    use junction <- list.flat_map(junctions)
    use neighbor <- list.filter_map(junction_neighbors(junction))
    case dict.has_key(trails, neighbor) {
      True -> Ok(start_walking_to_next_junction(junction, neighbor, trails))
      False -> Error(Nil)
    }
  }
  |> list.fold(dict.new(), fn(acc, edge) {
    let #(from, route) = edge
    use v <- dict.update(acc, from)
    case v {
      None -> [route]
      Some(routes) -> [route, ..routes]
    }
  })
}

fn generate_2way_routes(
  junctions: List(Posn),
  trails: Array2D(Path),
) -> Dict(Posn, List(Route)) {
  let routes = {
    use junction <- list.flat_map(junctions)
    use neighbor <- list.filter_map(junction_neighbors(junction))
    case dict.has_key(trails, neighbor) {
      True -> Ok(start_walking_to_next_junction(junction, neighbor, trails))
      False -> Error(Nil)
    }
  }
  use acc, r <- list.fold(routes, dict.new())
  let #(from, Route(to, dist)) = r
  acc
  |> dict.update(from, append_to_key(_, Route(to, dist)))
  |> dict.update(to, append_to_key(_, Route(from, dist)))
}

fn dfs(routes, from, to) {
  let seen = set.insert(set.new(), from)
  do_dfs(routes, from, to, 0, seen)
}

fn do_dfs(
  routes: Dict(Posn, List(Route)),
  from: Posn,
  to: Posn,
  acc: Int,
  seen: Set(Posn),
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
  using: fn(List(Posn), Dict(Posn, Path)) -> Dict(Posn, List(Route)),
) -> Int {
  let min_row = 0
  let max_row = list.length(string.split(input, "\n")) - 1

  let trails =
    input
    |> array2d.parse_grid_using(first_parse_path)
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

pub fn part1(input: String) {
  solve_using(input, generate_routes)
}

pub fn part2(input: String) {
  solve_using(input, generate_2way_routes)
}

pub fn main() {
  let assert Ok(part) = adglent.get_part()
  let assert Ok(input) = adglent.get_input("23")
  case part {
    First ->
      part1(input)
      |> adglent.inspect
      |> io.println
    Second ->
      part2(input)
      |> adglent.inspect
      |> io.println
  }
}

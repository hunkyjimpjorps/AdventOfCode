import gleam/dict.{type Dict}
import gleam/list
import gleam/string

pub fn parse(input: String) -> Dict(String, String) {
  input
  |> string.split("\n")
  |> list.fold(dict.new(), fn(acc, line) {
    let assert [orbiting, orbiter] = string.split(line, ")")
    dict.insert(acc, orbiter, orbiting)
  })
}

fn count_superorbits(object: a, orbits: Dict(a, a)) -> Int {
  case dict.get(orbits, object) {
    Error(_) -> 0
    Ok(orbited) -> 1 + count_superorbits(orbited, orbits)
  }
}

pub fn pt_1(orbits: Dict(String, String)) -> Int {
  list.fold(dict.keys(orbits), 0, fn(count, object) {
    count + count_superorbits(object, orbits)
  })
}

fn build_orbital_path(object: a, orbits: Dict(a, a)) -> List(a) {
  do_build_path(object, orbits, [])
}

fn do_build_path(object: a, orbits: Dict(a, a), acc: List(a)) -> List(a) {
  case dict.get(orbits, object) {
    Error(_) -> [object, ..acc]
    Ok(orbited) -> do_build_path(orbited, orbits, [object, ..acc])
  }
}

fn find_pivot(xs: List(a), ys: List(a)) -> Int {
  case xs, ys {
    [x, ..xs], [y, ..ys] if x == y -> find_pivot(xs, ys)
    xs, ys -> list.length(xs) + list.length(ys) - 2
  }
}

pub fn pt_2(orbits: Dict(String, String)) -> Int {
  let to_you = build_orbital_path("YOU", orbits)
  let to_santa = build_orbital_path("SAN", orbits)

  find_pivot(to_you, to_santa)
}

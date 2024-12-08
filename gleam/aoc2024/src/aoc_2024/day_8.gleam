import gleam/dict.{type Dict}
import gleam/list
import gleam/option.{None, Some}
import gleam/set
import my_utils/coord.{type Coord}
import my_utils/from

pub type Cell {
  Open
  Antenna(String)
}

pub type Map =
  Dict(Coord, Cell)

pub fn parse(input: String) -> Map {
  from.grid(input, fn(c) {
    case c {
      "." -> Open
      chr -> Antenna(chr)
    }
  })
}

fn collect_antennas(input: Map) -> Dict(Cell, List(Coord)) {
  use acc, k, v <- dict.fold(input, dict.new())
  use coords <- dict.upsert(acc, v)
  case coords {
    None -> [k]
    Some(_) if v == Open -> []
    Some(vs) -> [k, ..vs]
  }
}

fn find_antinodes(coords: List(Coord), map) -> List(Coord) {
  coords
  |> list.combinations(2)
  |> list.flat_map(fn(pair) {
    let assert [first, second] = pair
    [
      coord.go(second, coord.dist(first, second)),
      coord.go(first, coord.dist(second, first)),
    ]
    |> list.filter(dict.has_key(map, _))
  })
}

pub fn pt_1(input: Map) {
  input
  |> collect_antennas
  |> dict.values()
  |> list.flat_map(find_antinodes(_, input))
  |> set.from_list
  |> set.size
}

fn find_resonant_antinodes(coords: List(Coord), map: Map) -> List(Coord) {
  coords
  |> list.combinations(2)
  |> list.flat_map(fn(pair) {
    let assert [first, second] = pair
    list.flatten([
      next_antinode(second, coord.dist(first, second), map, []),
      next_antinode(first, coord.dist(second, first), map, []),
    ])
  })
}

fn next_antinode(coord, offset, map, acc) {
  case dict.has_key(map, coord) {
    True -> next_antinode(coord.go(coord, offset), offset, map, [coord, ..acc])
    False -> acc
  }
}

pub fn pt_2(input: Map) {
  input
  |> collect_antennas
  |> dict.values()
  |> list.flat_map(find_resonant_antinodes(_, input))
  |> set.from_list
  |> set.size()
}

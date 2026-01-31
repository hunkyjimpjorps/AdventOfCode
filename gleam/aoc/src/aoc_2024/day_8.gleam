import gleam/dict.{type Dict}
import gleam/list
import gleam/option.{None, Some}
import gleam/set
import my_utils/from
import my_utils/xy.{type XY}

pub type Cell {
  Open
  Antenna(String)
}

pub type Map =
  Dict(XY, Cell)

pub fn parse(input: String) -> Map {
  from.grid(input, xy.from_input, fn(c) {
    case c {
      "." -> Open
      antenna -> Antenna(antenna)
    }
  })
}

fn collect_antennas(input: Map) -> Dict(Cell, List(XY)) {
  use acc, coord, antenna <- dict.fold(input, dict.new())
  use coords <- dict.upsert(acc, antenna)
  case coords {
    _ if antenna == Open -> []
    None -> [coord]
    Some(coords) -> [coord, ..coords]
  }
}

fn find_antinodes(coords: List(XY), map) -> List(XY) {
  coords
  |> list.combinations(2)
  |> list.flat_map(fn(pair) {
    let assert [first, second] = pair
    [
      xy.go(second, xy.dist(first, second)),
      xy.go(first, xy.dist(second, first)),
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

fn find_resonant_antinodes(coords: List(XY), map: Map) -> List(XY) {
  coords
  |> list.combinations(2)
  |> list.flat_map(fn(pair) {
    let assert [first, second] = pair
    list.flatten([
      next_antinode(second, xy.dist(first, second), map, []),
      next_antinode(first, xy.dist(second, first), map, []),
    ])
  })
}

fn next_antinode(coord, offset, map, acc) {
  case dict.has_key(map, coord) {
    True -> next_antinode(xy.go(coord, offset), offset, map, [coord, ..acc])
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

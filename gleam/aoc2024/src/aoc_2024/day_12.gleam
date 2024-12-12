import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/set.{type Set}
import my_utils/coord.{type Coord, Coord}
import my_utils/from

pub fn parse(input: String) -> Dict(Coord, String) {
  from.grid(input, fn(c) { c })
}

fn find_contiguous_regions(
  field: Dict(Coord, String),
  acc: List(Set(Coord)),
) -> List(Set(Coord)) {
  case dict.keys(field) {
    [next, ..] -> {
      let plant = dict.get(field, next)
      let region = flood_fill(field, [next], set.new(), plant)
      let new_field = dict.drop(field, set.to_list(region))
      find_contiguous_regions(new_field, [region, ..acc])
    }
    [] -> acc
  }
}

fn flood_fill(field, stack, seen, plant) {
  case stack {
    [] -> seen
    [first, ..rest] ->
      case !set.contains(seen, first) && dict.get(field, first) == plant {
        False -> flood_fill(field, rest, seen, plant)
        True -> {
          let new_stack =
            list.append(rest, coord.neighbors(first, coord.cardinal_directions))
          let new_seen = set.insert(seen, first)
          flood_fill(field, new_stack, new_seen, plant)
        }
      }
  }
}

fn get_perimeter(field: Set(Coord)) -> Int {
  field
  |> set.fold(0, fn(acc, pt) {
    pt
    |> coord.neighbors(coord.cardinal_directions)
    |> list.count(fn(n) { !set.contains(field, n) })
    |> int.add(acc)
  })
}

pub fn pt_1(input: Dict(Coord, String)) {
  let regions = find_contiguous_regions(input, [])

  list.fold(regions, 0, fn(acc, region) {
    let perimeter = get_perimeter(region)
    let area = set.size(region)

    acc + area * perimeter
  })
}

fn get_sides(field: Set(Coord)) -> Int {
  // an n-gon has n vertices, so count all the places a vertex occurs instead
  field
  |> set.fold(0, fn(acc, pt) {
    let assert [up, up_right, right, down_right, down, down_left, left, up_left] =
      pt
      |> coord.neighbors(coord.eight_directions)
      |> list.map(fn(n) { set.contains(field, n) })
    [
      !up && !left,
      !up && !right,
      !down && !left,
      !down && !right,
      up && left && !up_left,
      up && right && !up_right,
      down && left && !down_left,
      down && right && !down_right,
    ]
    |> list.count(fn(bool) { bool })
    |> int.add(acc)
  })
}

pub fn pt_2(input: Dict(Coord, String)) {
  let regions = find_contiguous_regions(input, [])

  list.fold(regions, 0, fn(acc, region) {
    let sides = get_sides(region)
    let area = set.size(region)

    acc + area * sides
  })
}

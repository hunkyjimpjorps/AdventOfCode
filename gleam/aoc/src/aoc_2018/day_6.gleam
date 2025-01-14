import gleam/dict
import gleam/int
import gleam/list
import gleam/option
import gleam/set.{type Set}
import my_utils/math
import my_utils/to
import my_utils/xy.{type XY, XY}

pub fn parse(input: String) -> #(List(XY), Set(XY), List(XY)) {
  let coords = to.list_of_xys(input, ", ")

  let xs = coords |> list.map(fn(xy) { xy.x })
  let ys = coords |> list.map(fn(xy) { xy.y })

  let x_min = math.min(xs)
  let x_max = math.max(xs)
  let y_min = math.min(ys)
  let y_max = math.max(ys)

  let boundary =
    [
      list.map(list.range(x_min, x_max), XY(_, y_min)),
      list.map(list.range(x_min, x_max), XY(_, y_max)),
      list.map(list.range(y_min, y_max), XY(x_min, _)),
      list.map(list.range(y_min, y_max), XY(x_max, _)),
    ]
    |> list.flatten
    |> set.from_list

  let all_points =
    list.flat_map(list.range(x_min, x_max), fn(x) {
      list.map(list.range(y_min, y_max), XY(x, _))
    })

  #(coords, boundary, all_points)
}

pub fn pt_1(input: #(List(XY), Set(XY), List(XY))) {
  let #(coords, boundary, all_points) = input

  let closest_points =
    coords |> list.map(fn(c) { #(c, set.new()) }) |> dict.from_list

  list.fold(all_points, closest_points, fn(acc, p) {
    let assert [closest, next_closest, ..] =
      list.sort(coords, fn(a, b) {
        int.compare(xy.manhattan_dist(a, p), xy.manhattan_dist(b, p))
      })
    case xy.manhattan_dist(closest, p) == xy.manhattan_dist(next_closest, p) {
      True -> acc
      False ->
        dict.upsert(acc, closest, fn(v) {
          let assert option.Some(v) = v
          set.insert(v, p)
        })
    }
  })
  |> dict.filter(fn(_, v) { set.is_disjoint(v, boundary) })
  |> dict.values
  |> list.map(set.size)
  |> math.max
}

pub fn pt_2(input: #(List(XY), Set(XY), List(XY))) {
  let #(coords, _, all_points) = input

  list.fold(all_points, 0, fn(acc, p) {
    let total_distance =
      list.fold(coords, 0, fn(dist, q) { dist + xy.manhattan_dist(p, q) })

    case total_distance < 10_000 {
      True -> acc + 1
      False -> acc
    }
  })
}

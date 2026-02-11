import gleam/dict
import gleam/float
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/set.{type Set}
import gleam/string
import gleam_community/maths
import my_utils/math
import my_utils/xy.{type XY, XY}

pub fn parse(input: String) -> Parsed {
  {
    use row, r <- list.index_map(string.split(input, "\n"))
    use col, c <- list.index_map(string.to_graphemes(row))
    case col {
      "#" -> Ok(XY(c, r))
      _ -> Error(Nil)
    }
  }
  |> list.flatten
  |> result.values
  |> set.from_list
}

type Parsed =
  Set(XY)

fn angle_from_point(origin: XY, to: XY) -> Float {
  maths.atan2(int.to_float(to.x - origin.x), int.to_float(to.y - origin.y))
}

fn dist(origin: XY, to: XY) -> Float {
  let assert Ok(d) =
    float.square_root(
      math.pow_f(int.to_float(to.x - origin.x), 2)
      +. math.pow_f(int.to_float(to.y - origin.y), 2),
    )
  d
}

fn find_base(asteroids: Set(XY)) -> #(XY, Int) {
  let assert Ok(base) =
    list.map(set.to_list(asteroids), fn(a) { #(a, count_angles(a, asteroids)) })
    |> list.max(fn(a, b) { int.compare(a.1, b.1) })
  base
}

fn count_angles(asteroid: XY, all_asteroids: Set(XY)) -> Int {
  all_asteroids
  |> set.delete(asteroid)
  |> set.map(angle_from_point(asteroid, _))
  |> set.size
}

pub fn pt_1(input: Parsed) -> Int {
  find_base(input).1
}

fn tag_visible_asteroids(input: Set(XY), from base: XY) -> dict.Dict(Float, XY) {
  use acc, to <- set.fold(set.delete(input, base), dict.new())
  use visible <- dict.upsert(acc, angle_from_point(base, to))
  case visible {
    None -> to
    Some(a) ->
      case dist(base, a) >. dist(base, to) {
        True -> to
        False -> a
      }
  }
}

pub fn pt_2(input: Parsed) -> Int {
  let base = find_base(input).0

  let assert [#(_, XY(x, y)), ..] =
    input
    |> tag_visible_asteroids(from: base)
    |> dict.to_list
    |> list.sort(fn(a, b) { float.compare(b.0, a.0) })
    |> list.drop(199)

  x * 100 + y
}

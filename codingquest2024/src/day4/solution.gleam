import gleam/float
import gleam/io
import gleam/list
import gleam/regex
import gleam/result
import gleam/string
import simplifile

pub type Star {
  Star(name: String, x: Float, y: Float, z: Float)
}

pub fn main() {
  let assert Ok(data) = simplifile.read(from: "./src/day4/data.txt")

  let assert [_, ..stars] = string.split(data, "\n")

  stars
  |> list.map(parse_star_record)
  |> list.combination_pairs()
  |> list.map(star_distance)
  |> list.reduce(float.min)
  |> io.debug
}

fn parse_star_record(str: String) -> Star {
  let assert Ok(re) = regex.from_string("\\s{2,}")

  let assert [name, ..coords] = regex.split(with: re, content: str)
  let assert [_, x, y, z] =
    coords
    |> list.map(float.parse)
    |> result.values

  Star(name, x, y, z)
}

fn star_distance(stars: #(Star, Star)) -> Float {
  let #(star1, star2) = stars
  let assert Ok(dist) =
    float.square_root(
      sq(star1.x -. star2.x) +. sq(star1.y -. star2.y) +. sq(star1.z -. star2.z),
    )
  dist
}

fn sq(x: Float) -> Float {
  x *. x
}

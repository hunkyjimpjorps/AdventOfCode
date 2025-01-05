import gleam/int
import gleam/list
import gleam/string

fn to_sides(line: String) {
  line
  |> string.trim()
  |> string.split(" ")
  |> list.filter_map(int.parse(_))
}

fn is_triangle(sides: List(Int)) {
  let assert [a, b, c] = list.sort(sides, int.compare)
  a + b > c
}

pub fn pt_1(input: String) {
  input
  |> string.split("\n")
  |> list.map(to_sides)
  |> list.count(is_triangle)
}

pub fn pt_2(input: String) {
  input
  |> string.split("\n")
  |> list.map(to_sides)
  |> list.sized_chunk(3)
  |> list.flat_map(list.transpose)
  |> list.count(is_triangle)
}

import gleam/dict.{type Dict}
import gleam/io
import gleam/int
import gleam/list
import gleam/regex
import gleam/result
import gleam/string
import simplifile

type Atlas =
  Dict(String, Dict(String, Int))

pub fn main() {
  let assert Ok(data) = simplifile.read(from: "./src/day5/data.txt")

  let assert [table, routes] = string.split(data, "\n\n")
  let assert [header, ..rows] = string.split(table, "\n")

  let dests =
    header
    |> string.trim()
    |> split_on_many_spaces

  let atlas = build_atlas(rows, dests)

  routes
  |> string.split("\n")
  |> list.fold(0, fn(acc, route) { acc + find_total_distance(route, atlas) })
  |> io.debug
}

fn split_on_many_spaces(str) {
  let assert Ok(re_spaces) = regex.from_string("\\s+")
  regex.split(re_spaces, str)
}

fn build_atlas(rows, dests) {
  rows
  |> list.map(split_on_many_spaces)
  |> list.fold(dict.new(), fn(acc, row) {
    let assert [from, ..raw_dists] = row
    let assert Ok(dists) = list.try_map(raw_dists, int.parse)
    let to_dict =
      dests
      |> list.zip(dists)
      |> dict.from_list()

    dict.insert(acc, from, to_dict)
  })
}

fn dist_between(leg: #(String, String), dict: Atlas) -> Int {
  let assert Ok(dist) =
    dict
    |> dict.get(leg.0)
    |> result.try(dict.get(_, leg.1))

  dist
}

fn find_total_distance(row: String, atlas: Atlas) {
  let assert [_, route] = string.split(row, ": ")

  string.split(route, " -> ")
  |> list.window_by_2
  |> list.fold(0, fn(acc, leg) { acc + dist_between(leg, atlas) })
}

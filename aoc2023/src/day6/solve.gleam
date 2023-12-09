import adglent.{First, Second}
import gleam/io
import gleam/string
import gleam/int
import gleam/list
import gleam/result

type Race {
  Race(time: Int, distance: Int)
}

fn parse_with_bad_kerning(input: String) {
  input
  |> string.split("\n")
  |> list.map(fn(str) {
    str
    |> string.split(" ")
    |> list.map(int.parse)
    |> result.values
  })
  |> list.transpose
  |> list.map(fn(ns) {
    let assert [t, d] = ns
    Race(t, d)
  })
}

fn find_bound(race: Race, button_time: Int, step: Int) {
  let travel_time = race.time - button_time
  case button_time * travel_time > race.distance {
    True -> button_time
    False -> find_bound(race, button_time + step, step)
  }
}

fn lower_bound(race: Race) {
  find_bound(race, 1, 1)
}

fn upper_bound(race: Race) {
  find_bound(race, race.time, -1)
}

pub fn part1(input: String) {
  {
    use acc, race <- list.fold(parse_with_bad_kerning(input), 1)
    acc * { upper_bound(race) - lower_bound(race) + 1 }
  }
  |> string.inspect
}

fn parse_properly(input: String) {
  input
  |> string.replace(" ", "")
  |> string.split("\n")
  |> list.flat_map(string.split(_, ":"))
  |> list.map(int.parse)
  |> result.values
}

pub fn part2(input: String) {
  let assert [time, distance] =
    input
    |> parse_properly

  let race = Race(time, distance)

  upper_bound(race) - lower_bound(race) + 1
  |> string.inspect
}

pub fn main() {
  let assert Ok(part) = adglent.get_part()
  let assert Ok(input) = adglent.get_input("6")
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

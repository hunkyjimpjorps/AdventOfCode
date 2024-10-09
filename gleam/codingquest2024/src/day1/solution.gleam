import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/regex
import gleam/result
import gleam/string
import simplifile

pub type Adjustment {
  Adjustment(spaceliner: String, value: Int)
}

pub fn main() {
  let assert Ok(data) = simplifile.read(from: "./src/day1/data.txt")

  let raw_adjustments = string.split(data, "\n")

  raw_adjustments
  |> collate_adjustments
  |> dict.values
  |> list.reduce(with: int.min)
  |> result.unwrap(0)
  |> int.to_string()
  |> io.println()
}

fn parse_line(line: String) -> Adjustment {
  let assert Ok(re) = regex.from_string("[\\s:]+")

  let assert [spaceliner, kind, raw_value] =
    regex.split(with: re, content: line)

  let assert Ok(value) = int.parse(raw_value)
  Adjustment(spaceliner, classify_adjustment(kind) * value)
}

fn classify_adjustment(name: String) -> Int {
  case name {
    "Seat" | "Meals" | "Luggage" | "Fee" | "Tax" -> 1
    "Discount" | "Rebate" -> -1
    _ -> panic as "unknown adjustment kind"
  }
}

fn collate_adjustments(raw_adjustments: List(String)) -> Dict(String, Int) {
  use acc, this <- list.fold(over: raw_adjustments, from: dict.new())
  let adjustment = parse_line(this)
  use maybe_v <- dict.update(in: acc, update: adjustment.spaceliner)
  case maybe_v {
    None -> adjustment.value
    Some(v) -> v + adjustment.value
  }
}

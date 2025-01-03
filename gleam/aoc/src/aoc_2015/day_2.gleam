import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub type Box {
  Box(length: Int, width: Int, height: Int)
}

fn paper_area(box: Box) -> Int {
  let assert Ok(smallest) =
    [box.length * box.width, box.width * box.height, box.height * box.length]
    |> list.reduce(int.min)

  { 2 * box.length * box.width }
  + { 2 * box.width * box.height }
  + { 2 * box.height * box.length }
  + smallest
}

fn parse_box(raw_box: String) -> Box {
  let assert [length, width, height] =
    raw_box |> string.split("x") |> list.map(int.parse) |> result.values()

  Box(length:, width:, height:)
}

fn parse_input(input: String) -> List(Box) {
  input
  |> string.split("\n")
  |> list.map(parse_box)
}

pub fn pt_1(input: String) {
  input
  |> parse_input
  |> list.fold(0, fn(sum, box) { sum + paper_area(box) })
}

fn bow_length(box: Box) {
  let assert Ok(smallest) =
    [
      2 * { box.length + box.width },
      2 * { box.width + box.height },
      2 * { box.height + box.length },
    ]
    |> list.reduce(int.min)
  let volume = box.height * box.length * box.width

  smallest + volume
}

pub fn pt_2(input: String) {
  input
  |> parse_input
  |> list.fold(0, fn(sum, box) { sum + bow_length(box) })
}

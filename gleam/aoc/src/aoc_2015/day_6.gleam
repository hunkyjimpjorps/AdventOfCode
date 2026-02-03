import gleam/dict
import gleam/list
import gleam/option.{Some}
import gleam/regexp
import gleam/string
import my_utils/to
import my_utils/xy.{type XY, XY}

pub type Instruction {
  TurnOn(from: XY, to: XY)
  TurnOff(from: XY, to: XY)
  Toggle(from: XY, to: XY)
}

pub fn parse(input: String) -> List(Instruction) {
  let assert Ok(re) = regexp.from_string("\\s|,")
  use line <- list.map(string.split(input, "\n"))
  case regexp.split(re, line) {
    ["turn", "on", x1, y1, _, x2, y2] ->
      TurnOn(XY(to.int(x1), to.int(y1)), XY(to.int(x2), to.int(y2)))
    ["turn", "off", x1, y1, _, x2, y2] ->
      TurnOff(XY(to.int(x1), to.int(y1)), XY(to.int(x2), to.int(y2)))
    ["toggle", x1, y1, _, x2, y2] ->
      Toggle(XY(to.int(x1), to.int(y1)), XY(to.int(x2), to.int(y2)))
    _ -> panic as "unrecognized instruction"
  }
}

pub fn pt_1(input: List(Instruction)) {
  list.range(from: 0, to: 1000 * 1000)
  |> list.map(fn(i) { #(i, 0) })
  |> dict.from_list
  |> update_lights(input, _)
}

pub fn update_lights(instructions: List(Instruction), lights) {
  case instructions {
    [] -> dict.fold(lights, 0, fn(acc, _, v) { acc + v })
    [next, ..rest] -> {
      let indices = {
        use y <- list.flat_map(list.range(next.from.y, next.to.y))
        use x <- list.map(list.range(next.from.x, next.to.x))
        x + 1000 * y
      }
      let op = case next {
        TurnOn(..) -> fn(_) { 1 }
        TurnOff(..) -> fn(_) { 0 }
        Toggle(..) -> fn(i) {
          case i {
            Some(0) -> 1
            Some(1) -> 0
            _ -> panic as string.inspect(i)
          }
        }
      }
      list.fold(indices, lights, fn(acc, i) { dict.upsert(acc, i, op) })
      |> update_lights(rest, _)
    }
  }
}

pub fn pt_2(input: List(Instruction)) {
  list.range(from: 0, to: 1000 * 1000)
  |> list.map(fn(i) { #(i, 0) })
  |> dict.from_list
  |> adjust_lights(input, _)
}

pub fn adjust_lights(instructions: List(Instruction), lights) {
  case instructions {
    [] -> dict.fold(lights, 0, fn(acc, _, v) { acc + v })
    [next, ..rest] -> {
      let indices = {
        use y <- list.flat_map(list.range(next.from.y, next.to.y))
        use x <- list.map(list.range(next.from.x, next.to.x))
        x + 1000 * y
      }
      let op = case next {
        TurnOn(..) -> fn(i) {
          case i {
            Some(i) -> i + 1
            _ -> panic
          }
        }
        TurnOff(..) -> fn(i) {
          case i {
            Some(0) -> 0
            Some(i) -> i - 1
            _ -> panic
          }
        }
        Toggle(..) -> fn(i) {
          case i {
            Some(i) -> i + 2
            _ -> panic
          }
        }
      }
      list.fold(indices, lights, fn(acc, i) { dict.upsert(acc, i, op) })
      |> adjust_lights(rest, _)
    }
  }
}

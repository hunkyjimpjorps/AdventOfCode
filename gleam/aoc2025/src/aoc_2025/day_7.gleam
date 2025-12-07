import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import my_utils/from
import my_utils/xy.{type XY, Down, Left, Right, XY}

pub type Cell {
  Start
  Splitter
  Empty
}

type Room =
  Dict(XY, Cell)

pub fn parse(input: String) {
  use c <- from.grid(input, XY)
  case c {
    "S" -> Start
    "^" -> Splitter
    _ -> Empty
  }
}

pub fn solve(input: Room) {
  let assert Ok(start) =
    input |> dict.filter(fn(_, v) { v == Start }) |> dict.keys |> list.first
  trace_beams(dict.from_list([#(start, 1)]), input, 0)
}

fn trace_beams(beams: Dict(XY, Int), room: Room, hits: Int) {
  let #(new_beams, new_hits) =
    dict.fold(beams, #(dict.new(), hits), fn(acc, k, v) {
      let next = k |> xy.step(Down) |> xy.step(Down)
      case dict.get(room, next) {
        Ok(Empty) | Ok(Start) -> #(
          dict.upsert(acc.0, next, increment(v, _)),
          acc.1,
        )
        Ok(Splitter) -> #(
          acc.0
            |> dict.upsert(next |> xy.step(Left), increment(v, _))
            |> dict.upsert(next |> xy.step(Right), increment(v, _)),
          acc.1 + 1,
        )
        Error(_) -> acc
      }
    })
  case dict.is_empty(new_beams) {
    True -> #(hits, beams |> dict.values |> int.sum)
    False -> trace_beams(new_beams, room, new_hits)
  }
}

fn increment(v, x) {
  case x {
    Some(i) -> i + v
    None -> v
  }
}

pub fn pt_1(input: Room) {
  solve(input).0
}

pub fn pt_2(input: Room) {
  solve(input).1
}

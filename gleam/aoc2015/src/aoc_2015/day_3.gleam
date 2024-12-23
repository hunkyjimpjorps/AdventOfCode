import gleam/bool
import gleam/list
import gleam/set.{type Set}
import gleam/string

type Direction {
  Up
  Down
  Left
  Right
}

type Position {
  Posn(x: Int, y: Int)
}

fn parse(input: String) -> List(Direction) {
  use ch <- list.map(string.to_graphemes(input))
  case ch {
    "^" -> Up
    "v" -> Down
    "<" -> Left
    ">" -> Right
    _ -> panic
  }
}

fn travel(moves: List(Direction), current: Position, visited: Set(Position)) {
  use <- bool.guard(list.is_empty(moves), visited)
  let assert [dir, ..rest] = moves
  let next = case dir {
    Up -> Posn(current.x, current.y + 1)
    Down -> Posn(current.x, current.y - 1)
    Left -> Posn(current.x - 1, current.y)
    Right -> Posn(current.x + 1, current.y)
  }
  travel(rest, next, set.insert(visited, next))
}

pub fn pt_1(input: String) {
  input
  |> parse
  |> travel(Posn(0, 0), set.insert(set.new(), Posn(0, 0)))
  |> set.size()
}

pub fn pt_2(input: String) {
  let assert [santa_route, robosanta_route] =
    input
    |> parse
    |> list.sized_chunk(into: 2)
    |> list.transpose

  let start = set.insert(set.new(), Posn(0, 0))

  let santa_houses = travel(santa_route, Posn(0, 0), start)
  let robosanta_houses = travel(robosanta_route, Posn(0, 0), start)

  set.union(santa_houses, robosanta_houses) |> set.size()
}

import adglent.{First, Second}
import gleam/io
import gleam/dict.{type Dict}
import gleam/string
import gleam/list
import gleam/int
import gleam/order.{Eq}
import gleam/result

type Coord {
  Coord(x: Int, y: Int)
}

type PartKind {
  Gear
  SomethingElse
}

type Symbol {
  Number(Int)
  Part(PartKind)
  Empty
}

type Board =
  Dict(Coord, Symbol)

fn to_symbol(c: String) -> Symbol {
  case int.parse(c), c {
    Ok(n), _ -> Number(n)
    Error(Nil), "." -> Empty
    Error(Nil), "*" -> Part(Gear)
    _, _ -> Part(SomethingElse)
  }
}

fn to_board(input: String) -> Board {
  {
    use y, r <- list.index_map(string.split(input, "\n"))
    use x, c <- list.index_map(string.to_graphemes(r))
    #(Coord(x, y), to_symbol(c))
  }
  |> list.flatten()
  |> dict.from_list()
}

fn find_all_parts(b: Board) {
  b
  |> dict.filter(fn(_, v) {
    case v {
      Number(_) -> True
      _ -> False
    }
  })
  |> dict.to_list()
  |> list.sort(fn(a, b) {
    let #(Coord(x_a, y_a), _) = a
    let #(Coord(x_b, y_b), _) = b
    case int.compare(y_a, y_b) {
      Eq -> int.compare(x_a, x_b)
      other -> other
    }
  })
}

fn group_parts(ns, acc) {
  case ns, acc {
    [], _ -> acc
    [#(Coord(x, y) as c, Number(n)), ..t], [
      #([Coord(x0, y0), ..] as cs, n0),
      ..acc_rest
    ] if y == y0 ->
      case { x - 1 == x0 } {
        True -> group_parts(t, [#([c, ..cs], n0 * 10 + n), ..acc_rest])
        False -> group_parts(t, [#([c], n), ..acc])
      }
    [#(coord, Number(n)), ..t], _ -> group_parts(t, [#([coord], n), ..acc])
  }
}

fn all_neighbors(c: Coord) -> List(Coord) {
  let Coord(x, y) = c
  use dx <- list.flat_map([-1, 0, 1])
  use dy <- list.filter_map([-1, 0, 1])
  case dx, dy {
    0, 0 -> Error(Nil)
    _, _ -> Ok(Coord(x + dx, y + dy))
  }
}

fn check_part_neighbors(
  part: #(List(Coord), Int),
  board: Board,
) -> Result(Int, Nil) {
  let #(coords, n) = part

  coords
  |> list.flat_map(all_neighbors)
  |> list.unique()
  |> list.map(dict.get(board, _))
  |> result.all()
  |> result.replace(n)
}

pub fn part1(input: String) {
  let board = to_board(input)

  board
  |> find_all_parts
  |> group_parts([])
  |> list.map(check_part_neighbors(_, board))
  |> result.values
  |> int.sum
}

fn to_part_with_neighbors(part: #(List(Coord), Int)) {
  let #(coords, n) = part

  let neighbors =
    coords
    |> list.flat_map(all_neighbors)
    |> list.unique
    |> list.filter(fn(c) { !list.contains(coords, c) })

  #(neighbors, n)
}

fn find_parts_near_gear(gear: Coord, parts: List(#(List(Coord), Int))) {
  parts
  |> list.filter_map(fn(part) {
    let #(neighbors, n) = part
    case list.contains(neighbors, gear) {
      True -> Ok(n)
      False -> Error(Nil)
    }
  })
}

fn keep_gears_near_two_parts(sets_of_parts: List(List(Int))) {
  use ps <- list.filter_map(sets_of_parts)
  case ps {
    [p1, p2] -> Ok(p1 * p2)
    _ -> Error(Nil)
  }
}

pub fn part2(input: String) {
  let board = to_board(input)

  let parts =
    board
    |> find_all_parts
    |> group_parts([])
    |> list.map(to_part_with_neighbors)

  board
  |> dict.filter(fn(_, v) { v == Part(Gear) })
  |> dict.keys
  |> list.map(find_parts_near_gear(_, parts))
  |> keep_gears_near_two_parts
  |> int.sum
}

pub fn main() {
  let assert Ok(part) = adglent.get_part()
  let assert Ok(input) = adglent.get_input("3")
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

import adglent.{First, Second}
import gleam/io
import gleam/dict.{type Dict}
import gleam/string
import gleam/list
import gleam/int
import gleam/order.{type Order, Eq}
import gleam/result

type Coord {
  Coord(x: Int, y: Int)
}

type SymbolKind {
  Gear
  SomethingElse
}

type Symbol {
  Number(Int)
  Symbol(SymbolKind)
  Empty
}

type Board =
  Dict(Coord, Symbol)

type Cell {
  Cell(coord: Coord, symbol: Symbol)
}

type Part {
  Part(coords: List(Coord), part_number: Int)
}

fn to_symbol(c: String) -> Symbol {
  case int.parse(c), c {
    Ok(n), _ -> Number(n)
    _, "." -> Empty
    _, "*" -> Symbol(Gear)
    _, _ -> Symbol(SomethingElse)
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

fn cell_compare(a: Cell, b: Cell) -> Order {
  case int.compare(a.coord.y, b.coord.y) {
    Eq -> int.compare(a.coord.x, b.coord.x)
    other -> other
  }
}

fn find_all_part_digits(b: Board) -> List(Cell) {
  b
  |> dict.filter(fn(_, v) {
    case v {
      Number(_) -> True
      _ -> False
    }
  })
  |> dict.to_list()
  |> list.map(fn(tup) { Cell(tup.0, tup.1) })
  |> list.sort(cell_compare)
}

fn to_parts(cells: List(Cell)) -> List(Part) {
  do_parts(cells, [])
}

fn do_parts(cells: List(Cell), parts: List(Part)) -> List(Part) {
  case cells {
    [] -> parts
    [Cell(next, Number(n)), ..t] -> {
      case parts {
        [] -> do_parts(t, [Part([next], n), ..parts])
        [Part([prev, ..] as coords, n0), ..rest_parts] ->
          case { next.x - prev.x }, { next.y - prev.y } {
            1, 0 ->
              do_parts(t, [Part([next, ..coords], n0 * 10 + n), ..rest_parts])
            _, _ -> do_parts(t, [Part([next], n), ..parts])
          }
      }
    }
  }
}

fn all_neighbors(c: Coord) -> List(Coord) {
  use dx <- list.flat_map([-1, 0, 1])
  use dy <- list.filter_map([-1, 0, 1])
  case dx, dy {
    0, 0 -> Error(Nil)
    _, _ -> Ok(Coord(c.x + dx, c.y + dy))
  }
}

fn check_part_neighbors(part: Part, board: Board) -> Result(Int, Nil) {
  let neighbors =
    part.coords
    |> list.flat_map(all_neighbors)
    |> list.unique()

  let sym = [Ok(Symbol(Gear)), Ok(Symbol(SomethingElse))]
  case list.any(neighbors, fn(c) { list.contains(sym, dict.get(board, c)) }) {
    True -> Ok(part.part_number)
    False -> Error(Nil)
  }
}

pub fn part1(input: String) -> Int {
  let board = to_board(input)

  board
  |> find_all_part_digits
  |> to_parts
  |> io.debug
  |> list.map(check_part_neighbors(_, board))
  |> io.debug
  |> result.values
  |> int.sum
}

fn to_part_with_neighbors(part: Part) -> Part {
  part.coords
  |> list.flat_map(all_neighbors)
  |> list.unique
  |> Part(part.part_number)
}

fn find_part_numbers_near_gear(gear: Coord, parts: List(Part)) -> List(Int) {
  use part <- list.filter_map(parts)
  case list.contains(part.coords, gear) {
    True -> Ok(part.part_number)
    False -> Error(Nil)
  }
}

fn to_sum_of_gear_ratios(adjacent_parts: List(List(Int))) -> Int {
  use acc, ps <- list.fold(adjacent_parts, 0)
  case ps {
    [p1, p2] -> acc + p1 * p2
    _ -> acc
  }
}

pub fn part2(input: String) -> Int {
  let board = to_board(input)

  let parts =
    board
    |> find_all_part_digits
    |> to_parts
    |> list.map(to_part_with_neighbors)

  board
  |> dict.filter(fn(_, v) { v == Symbol(Gear) })
  |> dict.keys
  |> list.map(find_part_numbers_near_gear(_, parts))
  |> to_sum_of_gear_ratios
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

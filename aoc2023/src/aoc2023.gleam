import gleam/io
import gleam/string
import gleam/list
import gleam/int

pub fn main() {
  io.println("Hello from aoc2023!")
}

type Symbol {
  Period
  Symbol(String)
  Number(Int)
}

type CoordItem {
  CoordItem(List(#(Int, Int)), Symbol)
}

fn parse_grid1(input: String) {
  use line, x_coord <- list.index_map(string.split(input, "\n"))
  use char, y_coord <- list.index_map(string.to_graphemes(line), [])
  case char {
    "." -> [CoordItem([#(x_coord, y_coord)], Period), ..acc]
    x -> {
      case int.parse(x) {
        Error(_) -> [CoordItem([#(x_coord, y_coord)], Symbol(x)), ..acc]
        Ok(n) -> {
          case acc {
            [CoordItem(coords, Number(num)), ..rest] -> {
              let assert Ok(num) = int.digits(num, 10)
              let assert Ok(thing) = int.undigits(list.append(num, [n]), 10)
              [
                CoordItem([#(x_coord, y_coord), ..coords], Number(thing)),
                ..rest
              ]
            }
            _ -> [CoordItem([#(x_coord, y_coord)], Number(n)), ..acc]
          }
        }
      }
    }
  }
}

fn parse_grid(input: String) -> List(CoordItem) {
  let lines = string.split(input, "\n")
  list.index_fold(
    lines,
    [],
    fn(acc, line, x_coord) {
      let row =
        list.index_fold(
          string.to_graphemes(line),
          [],
          fn(acc, char, y_coord) {
            case char {
              "." -> [CoordItem([#(x_coord, y_coord)], Period), ..acc]
              x -> {
                case int.parse(x) {
                  Error(_) -> [
                    CoordItem([#(x_coord, y_coord)], Symbol(x)),
                    ..acc
                  ]
                  Ok(n) -> {
                    case acc {
                      [CoordItem(coords, Number(num)), ..rest] -> {
                        let assert Ok(num) = int.digits(num, 10)
                        let assert Ok(thing) =
                          int.undigits(list.append(num, [n]), 10)
                        [
                          CoordItem(
                            [#(x_coord, y_coord), ..coords],
                            Number(thing),
                          ),
                          ..rest
                        ]
                      }
                      _ -> [CoordItem([#(x_coord, y_coord)], Number(n)), ..acc]
                    }
                  }
                }
              }
            }
          },
        )
      [row, ..acc]
    },
  )
  |> list.flatten
}

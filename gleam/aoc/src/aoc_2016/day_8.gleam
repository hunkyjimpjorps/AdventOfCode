import gleam/dict.{type Dict}
import gleam/io
import gleam/list
import gleam/string
import my_utils/coord.{type Coord, Coord}
import my_utils/to

const rowmax = 5

const colmax = 49

pub type Pixel {
  On
  Off
}

pub type Screen =
  Dict(Coord, Pixel)

pub type Instruction {
  Rect(rows: Int, cols: Int)
  RotateRow(row: Int, by: Int)
  RotateCol(col: Int, by: Int)
}

type Input =
  List(Instruction)

fn allocate(rows, cols, state) {
  list.flat_map(list.range(0, rows), fn(r) {
    list.map(list.range(0, cols), fn(c) { #(Coord(r, c), state) })
  })
  |> dict.from_list
}

fn initialize_screen() {
  allocate(rowmax, colmax, Off)
}

fn rect(screen, rows, cols) {
  dict.merge(screen, allocate(rows - 1, cols - 1, On))
}

fn rotate_row(screen, row, by) {
  list.fold(list.range(0, colmax), screen, fn(acc, c) {
    let assert Ok(pixel) = dict.get(screen, Coord(row, c))
    dict.insert(acc, Coord(row, { c + by } % { colmax + 1 }), pixel)
  })
}

fn rotate_col(screen, col, by) {
  list.fold(list.range(0, rowmax), screen, fn(acc, r) {
    let assert Ok(pixel) = dict.get(screen, Coord(r, col))
    dict.insert(acc, Coord({ r + by } % { rowmax + 1 }, col), pixel)
  })
}

fn parse_instruction(line: String) {
  case line {
    "rect " <> rest -> {
      let assert [x, y] = string.split(rest, "x")
      Rect(to.int(y), to.int(x))
    }
    "rotate row y=" <> rest -> {
      let assert [row, by] = string.split(rest, " by ")
      RotateRow(to.int(row), to.int(by))
    }
    "rotate column x=" <> rest -> {
      let assert [col, by] = string.split(rest, " by ")
      RotateCol(to.int(col), to.int(by))
    }
    _ -> panic as "unknown instruction"
  }
}

pub fn parse(input: String) {
  to.delimited_list(input, "\n", parse_instruction)
}

fn next_instruction(screen, instructions) {
  case instructions {
    [] -> screen
    [Rect(r, c), ..rest] -> next_instruction(rect(screen, r, c), rest)
    [RotateRow(r, by), ..rest] ->
      next_instruction(rotate_row(screen, r, by), rest)
    [RotateCol(c, by), ..rest] ->
      next_instruction(rotate_col(screen, c, by), rest)
  }
}

pub fn pt_1(input: Input) {
  initialize_screen()
  |> next_instruction(input)
  |> dict.values
  |> list.count(fn(p) { p == On })
}

fn print_screen(screen) {
  list.map(list.range(0, rowmax), fn(r) {
    list.map(list.range(0, colmax), fn(c) {
      case dict.get(screen, Coord(r, c)) {
        Ok(On) -> "██"
        Ok(Off) -> "░░"
        _ -> panic
      }
    })
    |> string.join("")
  })
  |> string.join("\n")
  |> io.println
}

pub fn pt_2(input: Input) {
  initialize_screen()
  |> next_instruction(input)
  |> print_screen
}

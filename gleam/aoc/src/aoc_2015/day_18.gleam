import gleam/bool
import gleam/dict
import gleam/list
import gleam/string

pub type Light {
  On
  Off
}

pub type Coord {
  Coord(x: Int, y: Int)
}

type Grid =
  dict.Dict(Coord, Light)

fn parse_grid(input: String) -> Grid {
  {
    use row, y <- list.index_map(string.split(input, "\n"))
    use col, x <- list.index_map(string.to_graphemes(row))
    case col {
      "#" -> #(Coord(x, y), On)
      "." -> #(Coord(x, y), Off)
      _ -> panic as "unrecognized light symbol"
    }
  }
  |> list.flatten
  |> dict.from_list
}

fn step_grid(grid: Grid) {
  use acc, pt, state <- dict.fold(grid, dict.new())
  let lit_neighbors =
    pt
    |> get_neighbors
    |> list.filter(fn(p) { dict.get(grid, p) == Ok(On) })
    |> list.length()

  let updated_state = case state, lit_neighbors {
    On, 2 | On, 3 -> On
    On, _ -> Off
    Off, 3 -> On
    Off, _ -> Off
  }

  dict.insert(acc, pt, updated_state)
}

fn get_neighbors(pt: Coord) {
  use x <- list.flat_map([pt.x - 1, pt.x, pt.x + 1])
  use y <- list.filter_map([pt.y - 1, pt.y, pt.y + 1])
  case x == pt.x && y == pt.y {
    True -> Error(Nil)
    False -> Ok(Coord(x, y))
  }
}

fn repeatedly_step(acc: Grid, using: fn(Grid) -> Grid, times: Int) {
  case times {
    0 -> acc
    n -> repeatedly_step(using(acc), using, n - 1)
  }
}

pub fn pt_1(input: String) {
  parse_grid(input)
  |> repeatedly_step(step_grid, 100)
  |> dict.filter(fn(_, v) { v == On })
  |> dict.values()
  |> list.length()
}

fn step_broken_grid(grid: Grid) {
  use acc, pt, state <- dict.fold(grid, dict.new())
  let lit_neighbors =
    pt
    |> get_neighbors
    |> list.filter(fn(p) { dict.get(grid, p) == Ok(On) })
    |> list.length()

  let updated_state = {
    use <- bool.guard(
      pt == Coord(0, 0)
        || pt == Coord(0, 99)
        || pt == Coord(99, 0)
        || pt == Coord(99, 99),
      On,
    )
    case state, lit_neighbors {
      On, 2 | On, 3 -> On
      On, _ -> Off
      Off, 3 -> On
      Off, _ -> Off
    }
  }

  dict.insert(acc, pt, updated_state)
}

pub fn pt_2(input: String) {
  parse_grid(input)
  |> dict.insert(Coord(0, 0), On)
  |> dict.insert(Coord(99, 0), On)
  |> dict.insert(Coord(0, 99), On)
  |> dict.insert(Coord(99, 99), On)
  |> repeatedly_step(step_broken_grid, 100)
  |> dict.filter(fn(_, v) { v == On })
  |> dict.values()
  |> list.length()
}

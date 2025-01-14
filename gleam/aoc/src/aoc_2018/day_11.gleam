import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import my_utils/to
import my_utils/xy.{type XY, XY}

pub fn parse(input: String) -> Int {
  to.int(input)
}

fn to_power_level(x: Int, y: Int, serial: Int) -> Int {
  let rack_id = x + 10

  rack_id
  |> int.multiply(y)
  |> int.add(serial)
  |> int.multiply(rack_id)
  |> fn(n) { { n / 100 } % 10 }
  |> int.subtract(5)
}

fn generate_grid(serial: Int) -> Dict(XY, Int) {
  use outer_acc, y <- list.fold(list.range(1, 300), dict.new())
  use inner_acc, x <- list.fold(list.range(1, 300), outer_acc)
  let left = dict.get(inner_acc, XY(x - 1, y)) |> result.unwrap(0)
  let up = dict.get(inner_acc, XY(x, y - 1)) |> result.unwrap(0)
  let up_left = dict.get(inner_acc, XY(x - 1, y - 1)) |> result.unwrap(0)

  dict.insert(
    inner_acc,
    XY(x, y),
    to_power_level(x, y, serial) + left + up - up_left,
  )
}

fn get_with_offset(dict: Dict(XY, Int), coord: XY, dx: Int, dy: Int) -> Int {
  dict.get(dict, XY(coord.x + dx, coord.y + dy)) |> result.unwrap(0)
}

fn find_best_square_of_size(grid: Dict(XY, Int), size: Int) -> #(Int, XY, Int) {
  let search_range = {
    use y <- list.flat_map(list.range(1, 300 - size + 1))
    use x <- list.map(list.range(1, 300 - size + 1))
    XY(x, y)
  }
  use acc, coord <- list.fold(search_range, #(0, XY(0, 0), size))
  let get = fn(x, y) { get_with_offset(grid, coord, x, y) }
  let total_sum = get(size - 1, size - 1)
  let left_sum = get(-1, size - 1)
  let up_sum = get(size - 1, -1)
  let up_left_sum = get(-1, -1)
  let power = total_sum - left_sum - up_sum + up_left_sum
  case power > acc.0 {
    True -> #(power, coord, size)
    False -> acc
  }
}

fn find_best_of_all_squares(grid: Dict(XY, Int)) -> #(Int, XY, Int) {
  use acc, size <- list.fold(list.range(1, 300), #(0, XY(0, 0), 0))
  let best_for_size = find_best_square_of_size(grid, size)
  case best_for_size.0 > acc.0 {
    True -> best_for_size
    False -> acc
  }
}

fn format_coord(result: #(Int, XY, Int)) -> String {
  let #(_, coord, size) = result
  [coord.x, coord.y, size]
  |> list.map(int.to_string)
  |> string.join(",")
}

pub fn pt_1(input: Int) -> String {
  input |> generate_grid |> find_best_square_of_size(3) |> format_coord
}

pub fn pt_2(input: Int) -> String {
  input |> generate_grid |> find_best_of_all_squares() |> format_coord
}

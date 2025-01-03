import gleam/int
import gleam/list

pub type XY {
  XY(x: Int, y: Int)
}

pub fn from_input(row: Int, col: Int) {
  XY(x: col, y: row)
}

pub fn next_col(coord: XY) {
  XY(coord.x, coord.y + 1)
}

pub fn next_row(coord: XY) {
  XY(coord.x + 1, 0)
}

pub fn go(coord: XY, direction: XY) {
  XY(coord.x + direction.x, coord.y + direction.y)
}

pub fn dist(a: XY, b: XY) -> XY {
  XY(b.x - a.x, b.y - a.y)
}

pub fn manhattan_dist(a: XY, b: XY) -> Int {
  int.absolute_value(b.x - a.x) + int.absolute_value(b.y - a.y)
}

pub const origin = XY(0, 0)

pub const eight_directions = [
  XY(1, 0),
  XY(1, 1),
  XY(0, 1),
  XY(-1, 1),
  XY(-1, 0),
  XY(-1, -1),
  XY(0, -1),
  XY(1, -1),
]

pub const cardinal_directions = [XY(1, 0), XY(-1, 0), XY(0, 1), XY(0, -1)]

pub fn neighbors(p: XY, dirs: List(XY)) {
  list.map(dirs, go(p, _))
}

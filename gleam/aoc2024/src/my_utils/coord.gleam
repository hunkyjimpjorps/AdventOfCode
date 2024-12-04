pub type Coord {
  Coord(r: Int, c: Int)
}

pub fn next_col(coord: Coord) {
  Coord(coord.r, coord.c + 1)
}

pub fn next_row(coord: Coord) {
  Coord(coord.r + 1, 0)
}

pub fn go(coord: Coord, direction: Coord) {
  Coord(coord.r + direction.r, coord.c + direction.c)
}

pub const origin = Coord(0, 0)

pub const eight_directions = [
  Coord(-1, -1),
  Coord(-1, 0),
  Coord(-1, 1),
  Coord(0, -1),
  Coord(0, 1),
  Coord(1, -1),
  Coord(1, 0),
  Coord(1, 1),
]

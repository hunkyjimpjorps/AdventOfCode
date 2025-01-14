import gleam/io
import gleam/list
import gleam/option
import gleam/regexp.{Match}
import gleam/string
import my_utils/to
import my_utils/xy.{type XY, XY}

pub type Star {
  Star(posn: XY, vel: XY)
}

fn parse_star(line: String) {
  let assert Ok(re) =
    regexp.from_string(
      "position=< *([\\-0-9]+), *([\\-0-9]+)> velocity=< *([\\-0-9]+), *([\\-0-9]+)>",
    )

  let assert [Match(submatches:, ..)] = regexp.scan(with: re, content: line)
  let assert [star_x, star_y, vel_x, vel_y] =
    submatches |> option.values |> list.map(to.int)

  Star(XY(star_x, star_y), XY(vel_x, vel_y))
}

fn get_bounding_box(stars: List(Star)) {
  let assert [xs, ys] =
    stars
    |> list.map(fn(s) { [s.posn.x, s.posn.y] })
    |> list.transpose

  let #(x_min, x_max) = to.range(xs)
  let #(y_min, y_max) = to.range(ys)
  #(x_min, x_max, y_min, y_max)
}

fn calculate_bounding_area(stars: List(Star)) {
  let #(x_min, x_max, y_min, y_max) = get_bounding_box(stars)
  { x_max - x_min } * { y_max - y_min }
}

fn next_step(stars: List(Star), area: Int, time: Int) {
  let next_stars =
    list.map(stars, fn(star) {
      Star(..star, posn: XY(star.posn.x + star.vel.x, star.posn.y + star.vel.y))
    })
  let next_area = calculate_bounding_area(next_stars)

  case next_area >= area {
    True -> {
      print_message(stars)
      time
    }
    False -> next_step(next_stars, next_area, time + 1)
  }
}

fn print_message(stars) {
  let #(x_min, x_max, y_min, y_max) = get_bounding_box(stars)

  {
    use y <- list.map(list.range(y_min, y_max))
    use x <- list.map(list.range(x_min, x_max))
    case list.find(stars, fn(s) { s.posn == XY(x, y) }) {
      Ok(..) -> "██"
      Error(..) -> "░░"
    }
  }
  |> list.map(string.join(_, ""))
  |> string.join("\n")
  |> string.append("\n", _)
  |> io.println
}

pub fn parse(input: String) -> List(Star) {
  to.delimited_list(input, "\n", parse_star)
}

pub fn pt_1(input: List(Star)) {
  let starting_area = input |> calculate_bounding_area
  input |> next_step(starting_area, 0)
}

pub fn pt_2(_input: List(Star)) {
  "see part 1 solution"
}

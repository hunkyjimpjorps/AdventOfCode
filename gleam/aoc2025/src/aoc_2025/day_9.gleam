import gleam/int
import gleam/list
import gleam/result
import gleamy/priority_queue
import my_utils/to
import my_utils/xy.{type XY, XY}

pub fn parse(input: String) -> List(XY) {
  to.list_of_xys(input, ",")
}

fn area(pair: #(XY, XY)) {
  { int.absolute_value({ pair.0 }.x - { pair.1 }.x) + 1 }
  * { int.absolute_value({ pair.0 }.y - { pair.1 }.y) + 1 }
}

fn compare(pair1: #(XY, XY), pair2: #(XY, XY)) {
  int.compare(area(pair2), area(pair1))
}

pub fn pt_1(input: List(XY)) {
  input
  |> list.combination_pairs
  |> priority_queue.from_list(compare)
  |> priority_queue.peek
  |> result.map(area)
  |> result.unwrap(0)
}

fn rectangle_intersects(rect: #(XY, XY), poly_sides) {
  let #(XY(x1, y1), XY(x2, y2)) = rect

  let assert [rect_min_x, rect_max_x] = list.sort([x1, x2], int.compare)
  let assert [rect_min_y, rect_max_y] = list.sort([y1, y2], int.compare)

  use poly_side <- list.any(poly_sides)
  let #(XY(px1, py1), XY(px2, py2)) = poly_side
  !{
    int.max(px1, px2) <= rect_min_x
    || int.min(px1, px2) >= rect_max_x
    || int.max(py1, py2) <= rect_min_y
    || int.min(py1, py2) >= rect_max_y
  }
}

fn find_first_rectangle(candidates, poly_sides) {
  let assert Ok(#(rect, rest)) = priority_queue.pop(candidates)
  case rectangle_intersects(rect, poly_sides) {
    True -> find_first_rectangle(rest, poly_sides)
    False -> rect
  }
}

pub fn pt_2(input: List(XY)) {
  let assert [first, ..] = input
  let poly_sides = list.append(input, [first]) |> list.window_by_2

  input
  |> list.combination_pairs
  |> priority_queue.from_list(compare)
  |> find_first_rectangle(poly_sides)
  |> area
}

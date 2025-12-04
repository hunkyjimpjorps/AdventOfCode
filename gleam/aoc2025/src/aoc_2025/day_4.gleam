import gleam/list
import gleam/set.{type Set}
import my_utils/from
import my_utils/xy.{type XY}

type Grid =
  Set(XY)

pub fn parse(input: String) {
  from.try_point_set(input, fn(ch) { ch == "@" })
}

fn count_nearby_rolls(p: XY, grid: Grid) {
  p
  |> xy.neighbors(xy.eight_directions)
  |> list.count(fn(l) { set.contains(grid, l) })
}

fn can_be_removed(p: XY, grid: Grid) {
  count_nearby_rolls(p, grid) < 4
}

pub fn pt_1(input: Grid) {
  input
  |> set.filter(can_be_removed(_, input))
  |> set.size
}

fn keep_removing(grid: Grid, acc: Int) {
  let removable_rolls = set.filter(grid, can_be_removed(_, grid))
  case set.is_empty(removable_rolls) {
    True -> acc
    False ->
      removable_rolls
      |> set.fold(grid, fn(acc, roll) { set.delete(acc, roll) })
      |> keep_removing(acc + set.size(removable_rolls))
  }
}

pub fn pt_2(input: Grid) {
  keep_removing(input, 0)
}

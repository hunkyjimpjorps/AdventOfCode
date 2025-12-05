import gleam/list
import gleam/set.{type Set}
import my_utils/from
import my_utils/xy.{type XY}

pub fn parse(input: String) -> Set(XY) {
  from.try_point_set(input, fn(ch) { ch == "@" })
}

fn can_be_removed(p: XY, room: Set(XY)) -> Bool {
  let neighboring_rolls =
    p
    |> xy.neighbors(xy.eight_directions)
    |> list.count(set.contains(room, _))

  neighboring_rolls < 4
}

pub fn pt_1(input: Set(XY)) -> Int {
  input
  |> set.filter(can_be_removed(_, input))
  |> set.size
}

fn keep_removing(room: Set(XY), acc: Int) -> Int {
  let removable_rolls = set.filter(room, can_be_removed(_, room))
  case set.is_empty(removable_rolls) {
    True -> acc
    False ->
      removable_rolls
      |> set.difference(room, _)
      |> keep_removing(acc + set.size(removable_rolls))
  }
}

pub fn pt_2(input: Set(XY)) -> Int {
  keep_removing(input, 0)
}

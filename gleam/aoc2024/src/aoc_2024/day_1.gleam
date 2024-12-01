import gleam/int
import gleam/list
import gleam/string
import my_utils/to
import tote/bag

pub fn parse(input: String) -> List(List(Int)) {
  list.map(string.split(input, "\n"), to.ints(_, split_on: "   "))
  |> list.transpose()
}

pub fn pt_1(input: List(List(Int))) -> Int {
  input
  |> list.map(list.sort(_, int.compare))
  |> list.transpose()
  |> list.fold(0, fn(acc, ns) {
    let assert [a, b] = ns
    acc + int.absolute_value(a - b)
  })
}

pub fn pt_2(input: List(List(Int))) -> Int {
  let assert [first, second] = input
  let second = bag.from_list(second)

  list.fold(first, 0, fn(acc, n) { n * bag.copies(second, n) + acc })
}

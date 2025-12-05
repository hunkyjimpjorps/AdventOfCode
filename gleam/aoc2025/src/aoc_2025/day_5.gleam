import gleam/int
import gleam/list
import gleam/string
import my_utils/to

pub type Range {
  Range(from: Int, to: Int)
}

pub type Parsed {
  Parsed(ranges: List(Range), ingredients: List(Int))
}

pub fn parse(input: String) {
  let assert [ranges, ingredients] = string.split(input, "\n\n")

  let ranges =
    ranges
    |> string.split("\n")
    |> list.map(fn(str) {
      let assert [from, to] = string.split(str, "-")
      Range(to.int(from), to.int(to))
    })

  let ingredients = to.ints(ingredients, "\n")

  Parsed(ranges, ingredients)
}

fn is_fresh(ingredient: Int, ranges: List(Range)) {
  list.any(ranges, fn(r) { r.from <= ingredient && ingredient <= r.to })
}

pub fn pt_1(input: Parsed) {
  list.count(input.ingredients, is_fresh(_, input.ranges))
}

fn cover_range(ranges: List(Range), previous_end: Int, acc: Int) {
  case ranges {
    [] -> acc
    [h, ..t] if h.to <= previous_end -> cover_range(t, previous_end, acc)
    [h, ..t] if h.from <= previous_end ->
      cover_range(t, h.to, acc + h.to - previous_end)
    [h, ..t] -> cover_range(t, h.to, acc + h.to - h.from + 1)
  }
}

pub fn pt_2(input: Parsed) {
  input.ranges
  |> list.sort(fn(left, right) { int.compare(left.from, right.from) })
  |> cover_range(0, 0)
}

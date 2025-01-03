import gleam/int
import gleam/list
import gleam/option
import gleam/regexp.{Match}
import gleam/string

pub type Ingredient {
  Ingredient(
    capacity: Int,
    durability: Int,
    flavor: Int,
    texture: Int,
    calories: Int,
  )
}

fn parse_ingredient(line: String) {
  let assert Ok(re) =
    regexp.from_string(
      "capacity ([\\-0-9]+), durability ([\\-0-9]+), flavor ([\\-0-9]+), texture ([\\-0-9]+), calories ([\\-0-9]+)",
    )

  let assert [Match(_, matches)] = regexp.scan(line, with: re)

  matches
  |> option.values
  |> list.try_map(int.parse)
  |> fn(ns) {
    let assert Ok([c, d, f, t, k]) = ns
    Ingredient(c, d, f, t, k)
  }
}

fn recipes(max) {
  list.range(0, max)
  |> list.flat_map(fn(n) { list.map(list.range(0, max - n), fn(a) { [a, n] }) })
  |> list.flat_map(fn(ns) {
    list.map(list.range(0, max - int.sum(ns)), fn(b) { [b, ..ns] })
  })
  |> list.map(fn(ns) { [max - int.sum(ns), ..ns] })
}

fn value(recipe: List(Int), ingredients: List(Ingredient), limit: Bool) {
  let capacity = score(recipe, ingredients, fn(i) { i.capacity })
  let durability = score(recipe, ingredients, fn(i) { i.durability })
  let flavor = score(recipe, ingredients, fn(i) { i.flavor })
  let texture = score(recipe, ingredients, fn(i) { i.texture })
  let calories = score(recipe, ingredients, fn(i) { i.calories })

  case capacity * durability * flavor * texture {
    _ if limit && calories != 500 -> 0
    n -> n
  }
}

fn score(recipe, ingredients, factor) {
  recipe
  |> list.zip(ingredients)
  |> list.fold(0, fn(acc, tup) { acc + tup.0 * factor(tup.1) })
  |> int.max(0)
}

fn best_score(ingredients, volume volume: Int, with_calorie_limit limit: Bool) {
  list.fold(recipes(volume), 0, fn(acc, recipe) {
    int.max(acc, value(recipe, ingredients, limit))
  })
}

pub fn pt_1(input: String) {
  input
  |> string.split("\n")
  |> list.map(parse_ingredient)
  |> best_score(volume: 100, with_calorie_limit: False)
}

pub fn pt_2(input: String) {
  input
  |> string.split("\n")
  |> list.map(parse_ingredient)
  |> best_score(volume: 100, with_calorie_limit: True)
}

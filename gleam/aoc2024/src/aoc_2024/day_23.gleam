import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/set
import gleam/string

fn append_to_value(dict, key, value) {
  dict.upsert(dict, key, fn(v) {
    case v {
      Some(v) -> [value, ..v]
      None -> [value]
    }
  })
}

fn assert_get(dict, key) {
  let assert Ok(v) = dict.get(dict, key)
  v
}

pub fn parse(input: String) -> Dict(String, List(String)) {
  use acc, line <- list.fold(string.split(input, "\n"), dict.new())
  let assert [left, right] = string.split(line, "-")
  acc
  |> append_to_value(left, right)
  |> append_to_value(right, left)
}

pub fn pt_1(input: Dict(String, List(String))) {
  dict.fold(input, set.new(), fn(acc, k, v) {
    list.combinations(v, 2)
    |> list.map(list.prepend(_, k))
    |> list.filter(fn(vs) {
      list.all(list.permutations(vs), fn(perm) {
        let assert [first, ..rest] = perm
        list.all(rest, list.contains(assert_get(input, first), _))
      })
    })
    |> list.filter(fn(clique) { list.any(clique, string.starts_with(_, "t")) })
    |> list.map(list.sort(_, string.compare))
    |> list.fold(acc, set.insert)
  })
  |> set.size()
}

pub fn pt_2(input: Dict(String, List(String))) {
  let groups =
    list.flat_map(dict.keys(input), fn(key) {
      let potential_set =
        [key, ..assert_get(input, key)] |> list.sort(string.compare)
      list.map(potential_set, fn(p) {
        potential_set
        |> list.filter(list.contains([p, ..assert_get(input, p)], _))
        |> string.join(",")
      })
      |> list.unique()
    })

  let grouped_groups =
    groups
    |> list.group(fn(a) { list.count(groups, fn(b) { a == b }) })
    |> dict.map_values(fn(_, v) { v |> list.first() |> result.unwrap("") })

  grouped_groups
  |> dict.keys()
  |> list.reduce(int.max)
  |> result.try(dict.get(grouped_groups, _))
  |> result.unwrap("")
}

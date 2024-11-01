import gleam/int
import gleam/list
import gleam/order
import gleam/string

const eggnog = 150

fn parse_containers(input: String) {
  use line <- list.map(string.split(input, "\n"))
  let assert Ok(n) = int.parse(line)
  n
}

pub fn pt_1(input: String) {
  let containers = parse_containers(input)

  containers
  |> list.length()
  |> list.range(1, _)
  |> list.flat_map(fn(n) {
    list.combinations(containers, n)
    |> list.filter(fn(ns) { int.sum(ns) == eggnog })
  })
  |> list.length()
}

pub fn pt_2(input: String) {
  let containers =
    parse_containers(input) |> list.sort(by: order.reverse(int.compare))

  let assert Ok(minimum_count) =
    containers
    |> list.length()
    |> list.range(1, _)
    |> list.find(fn(n) {
      list.combinations(containers, n)
      |> list.any(fn(ns) { int.sum(ns) == eggnog })
    })

  list.combinations(containers, minimum_count)
  |> list.fold(0, fn(acc, combination) {
    case int.sum(combination) == eggnog {
      True -> acc + 1
      False -> acc
    }
  })
}

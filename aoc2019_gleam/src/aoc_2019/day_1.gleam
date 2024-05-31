import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub fn parse(input: String) -> List(Int) {
  input
  |> string.split("\n")
  |> list.map(int.parse)
  |> result.values()
}

pub fn pt_1(input: List(Int)) {
  input
  |> list.fold(0, fn(total, next) { total + naive_fuel(next) })
}

pub fn pt_2(input: List(Int)) {
  input
  |> list.fold(0, fn(total, next) { total + recursive_fuel(next) })
}

fn naive_fuel(weight: Int) -> Int {
  { weight / 3 } - 2
}

fn recursive_fuel(weight: Int) -> Int {
  case { weight / 3 } - 2 {
    n if n <= 0 -> 0
    n -> n + recursive_fuel(n)
  }
}

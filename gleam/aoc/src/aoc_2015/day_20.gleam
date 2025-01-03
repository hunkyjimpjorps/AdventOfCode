import gleam/int
import gleam/list
import gleam_community/maths/arithmetics

const target = 29_000_000

fn best_house_infinite(address: Int) {
  let presents = address |> arithmetics.divisors |> int.sum |> int.multiply(10)

  case presents >= target {
    True -> address
    False -> best_house_infinite(address + 1)
  }
}

pub fn pt_1(_input: String) {
  best_house_infinite(1)
}

fn best_house_limited(address: Int) {
  let presents =
    address
    |> arithmetics.divisors
    |> list.filter(fn(n) { n * 50 >= address })
    |> int.sum
    |> int.multiply(11)

  case presents >= target {
    True -> address
    False -> best_house_limited(address + 1)
  }
}

pub fn pt_2(_input: String) {
  best_house_limited(1)
}

import gleam/int
import gleam/list

pub fn pow(base: Int, exponent: Int) {
  case exponent {
    0 -> 1
    1 -> base
    n if n % 2 == 0 -> pow(base * base, n / 2)
    n -> base * pow(base, n - 1)
  }
}

pub fn divide(numerator: Int, denominator: Int) {
  numerator / denominator
}

pub fn min(xs: List(Int)) {
  let assert Ok(min) = list.reduce(xs, int.min)
  min
}

pub fn max(xs: List(Int)) {
  let assert Ok(max) = list.reduce(xs, int.max)
  max
}
